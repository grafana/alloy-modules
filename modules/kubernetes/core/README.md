# Agent Module

Handles scraping Grafana Agent metrics.

## Components

-   [`cadvisor`](#cadvisor)
-   [`resources`](#resources)
-   [`kubelet`](#kubelet)
-   [`apiserver`](#apiserver)
-   [`probes`](#probes)
-   [`kube_dns`](#kube_dns)

### `cadvisor`

Handles scraping and collecting kubelet [cAdvisor](https://github.com/google/cadvisor/blob/master/docs/storage/prometheus.md) metrics from each worker in the cluster.

#### Arguments

| Name                     | Required | Default                                    | Description                                                                                                                                        |
| :----------------------- | :------- | :----------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`             | _yes_    | `list(MetricsReceiver)`                    | Must be a where scraped should be forwarded to                                                                                                     |
| `field_selectors`        | _no_     | `["metadata.name=kubernetes"]`             | The [field selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/) to use to find matching targets          |
| `label_selectors`        | _no_     | `[]`                                       | The [label selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to use to find matching targets                   |
| `job_label`              | _no_     | `integrations/kubernetes/cadvisor`         | The job label to add for all metrics                                                                                                               |
| `keep_metrics`           | _no_     | [see code](module.alloy#L153)              | A regular expression of metrics to keep                                                                                                            |
| `drop_metrics`           | _no_     | [see code](module.alloy#L146)              | A regular expression of metrics to drop                                                                                                            |
| `scrape_interval`        | _no_     | `60s`                                      | How often to scrape metrics from the targets                                                                                                       |
| `scrape_timeout`         | _no_     | `10s`                                      | How long before a scrape times out                                                                                                                 |
| `max_cache_size`         | _no_     | `100000`                                   | The maximum number of elements to hold in the relabeling cache. This should be at least 2x-5x your largest scrape target or samples appended rate. |
| `clustering`             | _no_     | `false`                                    | Whether or not [clustering](https://grafana.com/docs/agent/latest/flow/concepts/clustering/) should be enabled                                     |
| `kubernetes_api_address` | _no_     | `kubernetes.default.svc.cluster.local:443` | Fully Qualified Domain Name (FQDN) and port for the Kubernetes API service in Kubernetes cluster                                                   |

#### Exports

M/A

#### Labels

The following labels are automatically added to exported targets.

| Label    | Description                                                                                       |
| :------- | :------------------------------------------------------------------------------------------------ |
| `app`    | Derived from the pod label value of `app.kubernetes.io/name`, `k8s-app`, or `app`                 |
| `job`    | Set to the value of `argument.job_label.value`                                                    |
| `node`   | Derived from the metadata label `__meta_kubernetes_node_name`                                     |
| `source` | Constant value of `kubernetes`, denoting where the results came from, this can be useful for LBAC |

---

### `resources`

Handles scraping and collecting kubelet [resource](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/) metrics from each worker in the cluster.

#### Arguments

| Name              | Required | Default                             | Description                                                                                                                                        |
| :---------------- | :------- | :---------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`      | _yes_    | `list(MetricsReceiver)`             | Must be a where scraped should be forwarded to                                                                                                     |
| `field_selectors` | _no_     | `["metadata.name=kubernetes"]`      | The [field selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/) to use to find matching targets          |
| `label_selectors` | _no_     | `[]`                                | The [label selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to use to find matching targets                   |
| `job_label`       | _no_     | `integrations/kubernetes/resources` | The job label to add for all metrics                                                                                                               |
| `keep_metrics`    | _no_     | [see code](module.alloy#L369)       | A regular expression of metrics to keep                                                                                                            |
| `drop_metrics`    | _no_     | [see code](module.alloy#L376)       | A regular expression of metrics to drop                                                                                                            |
| `scrape_interval` | _no_     | `60s`                               | How often to scrape metrics from the targets                                                                                                       |
| `scrape_timeout`  | _no_     | `10s`                               | How long before a scrape times out                                                                                                                 |
| `max_cache_size`  | _no_     | `100000`                            | The maximum number of elements to hold in the relabeling cache. This should be at least 2x-5x your largest scrape target or samples appended rate. |
| `clustering`      | _no_     | `false`                             | Whether or not [clustering](https://grafana.com/docs/agent/latest/flow/concepts/clustering/) should be enabled                                     |

#### Exports

M/A

#### Labels

The following labels are automatically added to exported targets.

| Label    | Description                                                                                       |
| :------- | :------------------------------------------------------------------------------------------------ |
| `app`    | Derived from the pod label value of `app.kubernetes.io/name`, `k8s-app`, or `app`                 |
| `job`    | Set to the value of `argument.job_label.value`                                                    |
| `node`   | Derived from the metadata label `__meta_kubernetes_node_name`                                     |
| `source` | Constant value of `kubernetes`, denoting where the results came from, this can be useful for LBAC |

---

### `kubelet`

Handles scraping and collecting [kubelet](https://kubernetes.io/docs/reference/instrumentation/metrics/) metrics from each worker in the cluster.

#### Arguments

| Name                     | Required | Default                                    | Description                                                                                                                                        |
| :----------------------- | :------- | :----------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`             | _yes_    | `list(MetricsReceiver)`                    | Must be a where scraped should be forwarded to                                                                                                     |
| `field_selectors`        | _no_     | `[]`                                       | The [field selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/) to use to find matching targets          |
| `label_selectors`        | _no_     | `[]`                                       | The [label selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to use to find matching targets                   |
| `job_label`              | _no_     | `integrations/kubernetes/kubelet`          | The job label to add for all metrics                                                                                                               |
| `keep_metrics`           | _no_     | [see code](module.alloy#L527)              | A regular expression of metrics to keep                                                                                                            |
| `drop_metrics`           | _no_     | [see code](module.alloy#L521)              | A regular expression of metrics to drop                                                                                                            |
| `scrape_interval`        | _no_     | `60s`                                      | How often to scrape metrics from the targets                                                                                                       |
| `scrape_timeout`         | _no_     | `10s`                                      | How long before a scrape times out                                                                                                                 |
| `max_cache_size`         | _no_     | `100000`                                   | The maximum number of elements to hold in the relabeling cache. This should be at least 2x-5x your largest scrape target or samples appended rate. |
| `clustering`             | _no_     | `false`                                    | Whether or not [clustering](https://grafana.com/docs/agent/latest/flow/concepts/clustering/) should be enabled                                     |
| `kubernetes_api_address` | _no_     | `kubernetes.default.svc.cluster.local:443` | Fully Qualified Domain Name (FQDN) and port for the Kubernetes API service in Kubernetes cluster                                                   |

#### Exports

M/A

#### Labels

The following labels are automatically added to exported targets.

| Label    | Description                                                                                       |
| :------- | :------------------------------------------------------------------------------------------------ |
| `app`    | Derived from the pod label value of `app.kubernetes.io/name`, `k8s-app`, or `app`                 |
| `job`    | Set to the value of `argument.job_label.value`                                                    |
| `node`   | Derived from the metadata label `__meta_kubernetes_node_name`                                     |
| `source` | Constant value of `kubernetes`, denoting where the results came from, this can be useful for LBAC |

---

### `apiserver`

Handles scraping and collecting [kube-apiserver](https://kubernetes.io/docs/concepts/overview/components/#kube-apiserver) metrics from the default kubernetes service.

#### Arguments

| Name              | Required | Default                             | Description                                                                                                                                        |
| :---------------- | :------- | :---------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`      | _yes_    | `list(MetricsReceiver)`             | Must be a where scraped should be forwarded to                                                                                                     |
| `namespaces`      | _no_     | `[]`                                | The namespaces to look for targets in, the default (`[]`) is all namespaces                                                                        |
| `port_name`       | _no_     | `https`                             | The of the port to scrape metrics from                                                                                                             |
| `field_selectors` | _no_     | `["metadata.name=kubernetes"]`      | The [field selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/) to use to find matching targets          |
| `label_selectors` | _no_     | `[]`                                | The [label selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to use to find matching targets                   |
| `job_label`       | _no_     | `integrations/kubernetes/apiserver` | The job label to add for all metrics                                                                                                               |
| `keep_metrics`    | _no_     | [see code](module.alloy#L703)       | A regular expression of metrics to keep                                                                                                            |
| `drop_metrics`    | _no_     | [see code](module.alloy#L686)       | A regular expression of metrics to drop                                                                                                            |
| `drop_les`        | _no_     | [see code](module.alloy#L693)       | A regular expression of metrics to drop                                                                                                            |
| `scrape_interval` | _no_     | `60s`                               | How often to scrape metrics from the targets                                                                                                       |
| `scrape_timeout`  | _no_     | `10s`                               | How long before a scrape times out                                                                                                                 |
| `max_cache_size`  | _no_     | `100000`                            | The maximum number of elements to hold in the relabeling cache. This should be at least 2x-5x your largest scrape target or samples appended rate. |
| `clustering`      | _no_     | `false`                             | Whether or not [clustering](https://grafana.com/docs/agent/latest/flow/concepts/clustering/) should be enabled                                     |

#### Exports

M/A

#### Labels

The following labels are automatically added to exported targets.

| Label       | Description                                                                                       |
| :---------- | :------------------------------------------------------------------------------------------------ |
| `app`       | Derived from the pod label value of `app.kubernetes.io/name`, `k8s-app`, or `app`                 |
| `job`       | Set to the value of `argument.job_label.value`                                                    |
| `namespace` | The namespace the target was found in.                                                            |
| `service`   | Derived from the metadata label `__meta_kubernetes_service_name`                                  |
| `source`    | Constant value of `kubernetes`, denoting where the results came from, this can be useful for LBAC |

---

### `probes`

Handles scraping and collecting Kubernetes Probe metrics from each worker in the cluster.

#### Arguments

| Name                     | Required | Default                                    | Description                                                                                                                                        |
| :----------------------- | :------- | :----------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`             | _yes_    | `list(MetricsReceiver)`                    | Must be a where scraped should be forwarded to                                                                                                     |
| `namespaces`             | _no_     | `[]`                                       | The namespaces to look for targets in, the default (`[]`) is all namespaces                                                                        |
| `port_name`              | _no_     | `https`                                    | The of the port to scrape metrics from                                                                                                             |
| `field_selectors`        | _no_     | `["metadata.name=kubernetes"]`             | The [field selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/) to use to find matching targets          |
| `label_selectors`        | _no_     | `[]`                                       | The [label selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to use to find matching targets                   |
| `job_label`              | _no_     | `integrations/kubernetes/probes`           | The job label to add for all metrics                                                                                                               |
| `keep_metrics`           | _no_     | [see code](module.alloy#L854)              | A regular expression of metrics to keep                                                                                                            |
| `drop_metrics`           | _no_     | [see code](module.alloy#L847)              | A regular expression of metrics to drop                                                                                                            |
| `scrape_interval`        | _no_     | `60s`                                      | How often to scrape metrics from the targets                                                                                                       |
| `scrape_timeout`         | _no_     | `10s`                                      | How long before a scrape times out                                                                                                                 |
| `max_cache_size`         | _no_     | `100000`                                   | The maximum number of elements to hold in the relabeling cache. This should be at least 2x-5x your largest scrape target or samples appended rate. |
| `clustering`             | _no_     | `false`                                    | Whether or not [clustering](https://grafana.com/docs/agent/latest/flow/concepts/clustering/) should be enabled                                     |
| `kubernetes_api_address` | _no_     | `kubernetes.default.svc.cluster.local:443` | Fully Qualified Domain Name (FQDN) and port for the Kubernetes API service in Kubernetes cluster                                                   |

#### Exports

M/A

#### Labels

The following labels are automatically added to exported targets.

| Label    | Description                                                                                       |
| :------- | :------------------------------------------------------------------------------------------------ |
| `app`    | Derived from the pod label value of `app.kubernetes.io/name`, `k8s-app`, or `app`                 |
| `job`    | Set to the value of `argument.job_label.value`                                                    |
| `node`   | Derived from the metadata label `__meta_kubernetes_node_name`                                     |
| `source` | Constant value of `kubernetes`, denoting where the results came from, this can be useful for LBAC |

---

### `kube_dns`

Handles scraping and collecting [CoreDNS/KubeDNS](https://coredns.io/plugins/metrics/) metrics from each pod.

#### Arguments

| Name              | Required | Default                            | Description                                                                                                                                        |
| :---------------- | :------- | :--------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`      | _yes_    | `list(MetricsReceiver)`            | Must be a where scraped should be forwarded to                                                                                                     |
| `namespaces`      | _no_     | `[]`                               | The namespaces to look for targets in, the default (`[]`) is all namespaces                                                                        |
| `port_name`       | _no_     | `https`                            | The of the port to scrape metrics from                                                                                                             |
| `namespaces`      | _no_     | `["kube-system"]`                  | The namespaces to look for targets in, the default (`[]`) is all namespaces                                                                        |
| `field_selectors` | _no_     | `[]`                               | The [field selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/) to use to find matching targets          |
| `label_selectors` | _no_     | `["k8s-app=kube-dns"]`             | The [label selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to use to find matching targets                   |
| `job_label`       | _no_     | `integrations/kubernetes/kube-dns` | The job label to add for all metrics                                                                                                               |
| `keep_metrics`    | _no_     | [see code](module.alloy#L1045)     | A regular expression of metrics to keep                                                                                                            |
| `drop_metrics`    | _no_     | [see code](module.alloy#L1038)     | A regular expression of metrics to drop                                                                                                            |
| `scrape_interval` | _no_     | `60s`                              | How often to scrape metrics from the targets                                                                                                       |
| `scrape_timeout`  | _no_     | `10s`                              | How long before a scrape times out                                                                                                                 |
| `max_cache_size`  | _no_     | `100000`                           | The maximum number of elements to hold in the relabeling cache. This should be at least 2x-5x your largest scrape target or samples appended rate. |
| `clustering`      | _no_     | `false`                            | Whether or not [clustering](https://grafana.com/docs/agent/latest/flow/concepts/clustering/) should be enabled                                     |

#### Exports

M/A

#### Labels

The following labels are automatically added to exported targets.

| Label       | Description                                                                                                                                         |
| :---------- | :-------------------------------------------------------------------------------------------------------------------------------------------------- |
| `app`       | Derived from the pod label value of `app.kubernetes.io/name`, `k8s-app`, or `app`                                                                   |
| `component` | Derived from the pod label value of `app.kubernetes.io/component`, `k8s-component`, or `component                                                   |
| `container` | The name of the container, usually `haproxy`                                                                                                        |
| `namespace` | The namespace the target was found in.                                                                                                              |
| `pod`       | The full name of the pod                                                                                                                            |
| `service`   | The name of the service the endpoint/pod is associated with, derived from the metadata label `__meta_kubernetes_service_name`                       |
| `source`    | Constant value of `kubernetes`, denoting where the results came from, this can be useful for LBAC                                                   |
| `workload`  | Kubernetes workload, a combination of `__meta_kubernetes_pod_controller_kind` and `__meta_kubernetes_pod_controller_name`, i.e. `ReplicaSet/my-app` |

---

## Usage

The following example will scrape all agents in cluster.

```alloy
import.git "k8s" {
  repository = "https://github.com/grafana/flow-modules.git"
  revision = "main"
  path = "modules/kubernetes/core/"etrics.river"
  pull_frequency = "15m"
}

k8s.cadvisor "scrape" {
  forward_to = [prometheus.remote_write.local.receiver]
}
k8s.resources "scrape" {
  forward_to = [prometheus.remote_write.local.receiver]
}
k8s.apiserver "scrape" {
  forward_to = [prometheus.remote_write.local.receiver]
}
k8s.probes "scrape" {
  forward_to = [prometheus.remote_write.local.receiver]
}
k8s.kube_dns "scrape" {
  forward_to = [prometheus.remote_write.local.receiver]
}
k8s.kubelet "scrape" {
  forward_to = [prometheus.remote_write.local.receiver]
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
