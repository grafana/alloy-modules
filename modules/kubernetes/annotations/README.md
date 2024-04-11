# Kubernetes Annotation Metric Module

**Modules:**

-   [`metrics.river`](#metricsriver)
-   [`probes.river`](#probesriver)

## `metrics.river`

This module is meant to be used to automatically scrape targets based on a certain role and set of annotations.  This module can be consumed
multiple times with different roles.  The supported roles are:

-   pod
-   service
-   endpoints

Typically, if mimicking the behavior of the prometheus-operator, and ServiceMonitor functionality you would use role="endpoints", if
mimicking the behavior of the PodMonitor functionality you would use role="pod".  It is important to understand that with endpoints,
the target is typically going to be a pod, and whatever annotations that are set on the service will automatically be propagated to the
endpoints.  This is why the role "endpoints" is used, because it will scrape the pod, but also consider the service annotations.  Using
role="endpoints", which scrape each endpoint associated to the service.  If role="service" is used, it will only scrape the service, only
hitting one of the endpoints associated to the service.

This is where you must consider your scraping strategy, for example if you scrape a service like "kube-state-metrics" using
role="endpoints" you should only have a single replica of the kube-state-metrics pod, if you have multiple replicas, you should use
role="service" or a separate non-annotation job completely.  Scraping a service instead of endpoints, is typically a rare use case, but
it is supported.

There are other considerations for using annotation based scraping as well, which is metric relabeling rules that happen post scrape.  If
you have a target that you want to apply a bunch of relabelings to or a very large metrics response payload, performance wise it will be
better to have a separate job for that target, rather than using use annotations.  As every targert will go through the ssame relabeling.
Typical deployment strategies/options would be:

**Option #1 (recommended):**

-   Annotation Scraping for role="endpoints"
-   Separate Jobs for specific service scrapes (i.e. kube-state-metrics, node-exporter, etc.) or large metric payloads
-   Separate Jobs for K8s API scraping (i.e. cadvisor, kube-apiserver, kube-scheduler, etc.)

**Option #2:**

-   Annotation Scraping for `role="pod"`
-   Annotation Scraping for `role="service"` (i.e. kube-state-metrics, node-exporter, etc.)
-   Separate Jobs for specific use cases or large metric payloads
-   Separate Jobs for K8s API scraping (i.e. cadvisor, kube-apiserver, kube-scheduler, etc.)

At no point should you use role="endpoints" and role="pod" together, as this will result in duplicate targets being scraped, thus
generating duplicate metrics.  If you want to scrape both the pod and the service, use Option #2.

Each port attached to an service/pod/endpoint is an eligible target, oftentimes it will have multiple ports.
There may be instances when you want to scrape all ports or some ports and not others. To support this
the following annotations are available:

```yaml
metrics.grafana.com/scrape: true
```

The default scraping scheme is http, this can be specified as a single value which would override, the schema being used for all
ports attached to the target:

```yaml
metrics.grafana.com/scheme: https
```

The default path to scrape is /metrics, this can be specified as a single value which would override, the scrape path being used
for all ports attached to the target:

```yaml
metrics.grafana.com/path: /metrics/some_path
```

The default port to scrape is the target port, this can be specified as a single value which would override the scrape port being
used for all ports attached to the target, note that even if aan target had multiple targets, the relabel_config targets are
deduped before scraping:

```yaml
metrics.grafana.com/port: 8080
```

The default interval to scrape is 1m, this can be specified as a single value which would override, the scrape interval being used
for all ports attached to the target:

```yaml
metrics.grafana.com/interval: 5m
```

The default timeout for scraping is 10s, this can be specified as a single value which would override, the scrape interval being
used for all ports attached to the target:

```yaml
metrics.grafana.com/timeout: 30s
```

The default job is namespace/{{ service name }} or namespace/{{ controller_name }} depending on the role, there may be instances
in which a different job name is required because of a set of dashboards, rules, etc. to support this there is a job annotation
which will override the default value:

```yaml
metrics.grafana.com/job: integrations/kubernetes/kube-state-metrics
```

### `kubernetes`

Handles discovery of kubernetes targets and exports them, this component does not perform any scraping at all and is not required to be used for kubernetes, as a custom service discovery and targets can be defined and passed to `cert_manager.scrape`

#### Arguments

| Name                        | Required | Default               | Description                                                                                                                                                                                                                                                                                                                                                                            |
| :-------------------------- | :------- | :-------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `role`                      | _no_     | `endpoints`           | The role to use when looking for targets to scrape via annotations, can be: endpoints, service, pod                                                                                                                                                                                                                                                                                    |
| `namespaces`                | _no_     | `[]`                  | The namespaces to look for targets in, the default (`[]`) is all namespaces                                                                                                                                                                                                                                                                                                            |
| `field_selectors`           | _no_     | `[]`                  | The [field selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/) to use to find matching targets                                                                                                                                                                                                                                              |
| `label_selectors`           | _no_     | `[]`                  | The [label selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to use to find matching targets                                                                                                                                                                                                                                                       |
| `annotation`                | _no_     | `metrics.grafana.com` | The domain to use when looking for annotations, Kubernetes selectors do not support a logical `OR`, if multiple types of annotations are needed, this module should be invoked multiple times.                                                                                                                                                                                         |
| `tenant`                    | _no_     | `.*`                  | The tenant to write metrics to.  This does not have to be the tenantId, this is the value to look for in the `{{argument.annotation.value}}/tenant` annotation i.e. (`metrics.grafana.com/tenant`), and this can be a regular expression.  It is recommended to use a default i.e. `primary\|`, which would match the primary tenant or an empty string meaning the tenant is not set. |
| `scrape_port_named_metrics` | _no_     | `false`               | Whether or not to automatically scrape targets that have a port with `.*metrics.*` in the name                                                                                                                                                                                                                                                                                         |

#### Exports

| Name     | Type                | Description                |
| :------- | :------------------ | :------------------------- |
| `output` | `list(map(string))` | List of discovered targets |

#### Labels

The following labels are automatically added to exported targets.

| Label       | Description                                                                                                                                         |
| :---------- | :-------------------------------------------------------------------------------------------------------------------------------------------------- |
| `app`       | Derived from the pod label value of `app.kubernetes.io/name`, `k8s-app`, or `app`                                                                   |
| `component` | Derived from the pod label value of `app.kubernetes.io/component`, `k8s-component`, or `component                                                   |
| `container` | The name of the container, usually `haproxy`                                                                                                        |
| `namespace` | The namespace the target was found in.                                                                                                              |
| `pod`       | The full name of the pod                                                                                                                            |
| `source`    | Constant value of `kubernetes`, denoting where the results came from, this can be useful for LBAC                                                   |
| `workload`  | Kubernetes workload, a combination of `__meta_kubernetes_pod_controller_kind` and `__meta_kubernetes_pod_controller_name`, i.e. `ReplicaSet/my-app` |

### `scrape`

#### Arguments

| Name              | Required | Default                       | Description                                                                                                                                         |
| :---------------- | :------- | :---------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------- |
| `targets`         | _yes_    | `list(map(string))`           | List of targets to scrape                                                                                                                           |
| `forward_to`      | _yes_    | `list(MetricsReceiver)`       | Must be a where scraped should be forwarded to                                                                                                      |
| `keep_metrics`    | _no_     | [see code](module.river#L228) | A regular expression of metrics to keep                                                                                                             |
| `drop_metrics`    | _no_     | [see code](module.river#L235) | A regular expression of metrics to drop                                                                                                             |
| `scrape_interval` | _no_     | `60s`                         | How often to scrape metrics from the targets                                                                                                        |
| `scrape_timeout`  | _no_     | `10s`                         | How long before a scrape times out                                                                                                                  |
| `max_cache_size`  | _no_     | `100000`                      | The maximum number of elements to hold in the relabeling cache.  This should be at least 2x-5x your largest scrape target or samples appended rate. |
| `clustering`      | _no_     | `false`                       | Whether or not [clustering](https://grafana.com/docs/agent/latest/flow/concepts/clustering/) should be enabled                                      |

#### Labels

N/A

---

## `probes.river`

This module is meant to be used to automatically scrape targets based on a certain role and set of annotations.  This module can be consumed
multiple times with different roles.  The supported roles are:

-   service
-   ingress

Each port attached to an service is an eligible target, oftentimes service will have multiple ports.
There may be instances when you want to probe all ports or some ports and not others. To support this
the following annotations are available:

Only probe services with probe set to true, this can be single valued i.e. probe all ports for
the service:

```yaml
probes.grafana.com/probe: true
```

The default probing scheme is "", this can be specified as a single value which would override,
if using HTTP prober specify "http" or "https":

```yaml
probes.grafana.com/scheme: https
```

The default path to probe is /metrics, this can be specified as a single value which would override,
the probe path being used for all ports attached to the service:

```yaml
probes.grafana.com/path: /metrics/some_path
```

The default module to use for probing the default value is "unknown" as the modules are defined are in your blackbox exporter
configuration file, this can be specified as a single value which would override, the probe module being used for all ports
attached to the service:

```yaml
probes.grafana.com/module: http_2xx
```

The default port to probe is the service port, this can be specified as a single value which would
override the probe port being used for all ports attached to the service, note that even if aan service had
multiple targets, the relabel_config targets are deduped before scraping:

```yaml
probes.grafana.com/port: 8080
```

The value to set for the job label, by default this would be "integrations/blackbox_exporter" if not specified:

```yaml
probes.grafana.com/job: blackbox-exporter
```

The default interval to probe is 1m, this can be specified as a single value which would override,
the probe interval being used for all ports attached to the service:

```yaml
probes.grafana.com/interval: 5m
```

The default timeout for scraping is 10s, this can be specified as a single value which would override,
the probe interval being used for all ports attached to the service:

```yaml
probes.grafana.com/timeout: 30s
```

### `kubernetes`

Handles discovery of kubernetes targets and exports them, this component does not perform any scraping at all and is not required to be used for kubernetes, as a custom service discovery and targets can be defined and passed to `cert_manager.scrape`

#### Arguments

| Name              | Required | Default               | Description                                                                                                                                                                                                                                                                                                                                                                            |
| :---------------- | :------- | :-------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `role`            | _no_     | `endpoints`           | The role to use when looking for targets to scrape via annotations, can be: endpoints, service, pod                                                                                                                                                                                                                                                                                    |
| `namespaces`      | _no_     | `[]`                  | The namespaces to look for targets in, the default (`[]`) is all namespaces                                                                                                                                                                                                                                                                                                            |
| `field_selectors` | _no_     | `[]`                  | The [field selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/) to use to find matching targets                                                                                                                                                                                                                                              |
| `label_selectors` | _no_     | `[]`                  | The [label selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to use to find matching targets                                                                                                                                                                                                                                                       |
| `annotation`      | _no_     | `metrics.grafana.com` | The domain to use when looking for annotations, Kubernetes selectors do not support a logical `OR`, if multiple types of annotations are needed, this module should be invoked multiple times.                                                                                                                                                                                         |
| `tenant`          | _no_     | `.*`                  | The tenant to write metrics to.  This does not have to be the tenantId, this is the value to look for in the `{{argument.annotation.value}}/tenant` annotation i.e. (`metrics.grafana.com/tenant`), and this can be a regular expression.  It is recommended to use a default i.e. `primary\|`, which would match the primary tenant or an empty string meaning the tenant is not set. |
| `blackbox_url`    | _no_     | `""`                  | The address of the blackbox exporter to use (without the protocol), only the hostname and port i.e. `blackbox-prometheus-blackbox-exporter.default.svc.cluster.local:9115`                                                                                                                                                                                                             |

#### Exports

| Name     | Type                | Description                |
| :------- | :------------------ | :------------------------- |
| `output` | `list(map(string))` | List of discovered targets |

#### Labels

The following labels are automatically added to exported targets.

| Label       | Description                                                                                                                                         |
| :---------- | :-------------------------------------------------------------------------------------------------------------------------------------------------- |
| `app`       | Derived from the pod label value of `app.kubernetes.io/name`, `k8s-app`, or `app`                                                                   |
| `component` | Derived from the pod label value of `app.kubernetes.io/component`, `k8s-component`, or `component                                                   |
| `namespace` | The namespace the target was found in.                                                                                                              |
| `source`    | Constant value of `kubernetes`, denoting where the results came from, this can be useful for LBAC                                                   |
| `workload`  | Kubernetes workload, a combination of `__meta_kubernetes_pod_controller_kind` and `__meta_kubernetes_pod_controller_name`, i.e. `ReplicaSet/my-app` |

### `scrape`

#### Arguments

| Name              | Required | Default                       | Description                                                                                                                                         |
| :---------------- | :------- | :---------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------- |
| `targets`         | _yes_    | `list(map(string))`           | List of targets to scrape                                                                                                                           |
| `forward_to`      | _yes_    | `list(MetricsReceiver)`       | Must be a where scraped should be forwarded to                                                                                                      |
| `keep_metrics`    | _no_     | [see code](module.river#L228) | A regular expression of metrics to keep                                                                                                             |
| `drop_metrics`    | _no_     | [see code](module.river#L235) | A regular expression of metrics to drop                                                                                                             |
| `scrape_interval` | _no_     | `60s`                         | How often to scrape metrics from the targets                                                                                                        |
| `scrape_timeout`  | _no_     | `10s`                         | How long before a scrape times out                                                                                                                  |
| `max_cache_size`  | _no_     | `100000`                      | The maximum number of elements to hold in the relabeling cache.  This should be at least 2x-5x your largest scrape target or samples appended rate. |
| `clustering`      | _no_     | `false`                       | Whether or not [clustering](https://grafana.com/docs/agent/latest/flow/concepts/clustering/) should be enabled                                      |

#### Labels

N/A

---

## Usage

### `metrics`

The following example will scrape all metric annotation instances in cluster.

```river
import.git "metric_annotations" {
  repository = "https://github.com/grafana/flow-modules.git"
  revision = "main"
  path = "modules/kubernetes/annotations/metrics.river"
  pull_frequency = "15m"
}

// get the targets
metric_annotations.kubernetes "targets" {
  annotation = "metrics.grafana.com"
}

// scrape the annotations
metric_annotations.scrape "metrics" {
  targets = metric_annotations.kubernetes.targets.output
  forward_to = [
    prometheus.remote_write.default.receiver,
  ]
}

// write the metrics
prometheus.remote_write "local" {
  endpoint {
    url = "http://mimir:9009/api/v1/push"

    basic_auth {
      username = "example-user"
      password = "example-password"
    }
  }
}
```

### `probes`

The following example will scrape all probe annotation instances in cluster.

```river
import.git "probe_annotations" {
  repository = "https://github.com/grafana/flow-modules.git"
  revision = "main"
  path = "modules/kubernetes/annotations/probes.river"
  pull_frequency = "15m"
}

// get the targets
probe_annotations.kubernetes "targets" {
  annotation = "probes.grafana.com"
}

// scrape the annotations
probe_annotations.scrape "probes" {
  targets = probe_annotations.kubernetes.targets.output
  forward_to = [
    prometheus.remote_write.default.receiver,
  ]
}

// write the metrics
prometheus.remote_write "local" {
  endpoint {
    url = "http://mimir:9009/api/v1/push"

    basic_auth {
      username = "example-user"
      password = "example-password"
    }
  }
}
```
