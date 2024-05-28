# pyroscope Module

Handles scraping pyroscope metrics.

## Components

-   [`kubernetes`](#kubernetes)
-   [`local`](#local)
-   [`scrape`](#scrape)

### `kubernetes`

Handles discovery of kubernetes targets and exports them, this component does not perform any scraping at all and is not required to be used for kubernetes, as a custom service discovery and targets can be defined and passed to `pyroscope.scrape`

#### Arguments

| Name              | Required | Default                                | Description                                                                                                                               |
| :---------------- | :------- | :------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------- |
| `namespaces`      | _no_     | `[]`                                   | The namespaces to look for targets in, the default (`[]`) is all namespaces                                                               |
| `field_selectors` | _no_     | `[]`                                   | The [field selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/) to use to find matching targets |
| `label_selectors` | _no_     | `["app.kubernetes.io/name=pyroscope"]` | The [label selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to use to find matching targets          |
| `port_name`       | _no_     | `http-metrics`                         | The of the port to scrape metrics from                                                                                                    |

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

---

### `local`

#### Arguments

| Name   | Optional | Default | Description                            |
| :----- | :------- | :------ | :------------------------------------- |
| `port` | `true`   | `4040`  | The of the port to scrape metrics from |

#### Exports

| Name     | Type                | Description                |
| :------- | :------------------ | :------------------------- |
| `output` | `list(map(string))` | List of discovered targets |

#### Labels

The following labels are automatically added to exported targets.

| Label    | Description                                                                                  |
| :------- | :------------------------------------------------------------------------------------------- |
| `source` | Constant value of `local`, denoting where the results came from, this can be useful for LBAC |

---

### `scrape`

#### Arguments

| Name              | Required | Default                       | Description                                                                                                                                         |
| :---------------- | :------- | :---------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------- |
| `targets`         | _yes_    | `list(map(string))`           | List of targets to scrape                                                                                                                           |
| `forward_to`      | _yes_    | `list(MetricsReceiver)`       | Must be a where scraped should be forwarded to                                                                                                      |
| `job_label`       | _no_     | `integrations/pyroscope`      | The job label to add for all pyroscope metric                                                                                                       |
| `keep_metrics`    | _no_     | [see code](module.river#L228) | A regular expression of metrics to keep                                                                                                             |
| `drop_metrics`    | _no_     | [see code](module.river#L235) | A regular expression of metrics to drop                                                                                                             |
| `scrape_interval` | _no_     | `60s`                         | How often to scrape metrics from the targets                                                                                                        |
| `scrape_timeout`  | _no_     | `10s`                         | How long before a scrape times out                                                                                                                  |
| `max_cache_size`  | _no_     | `100000`                      | The maximum number of elements to hold in the relabeling cache.  This should be at least 2x-5x your largest scrape target or samples appended rate. |
| `clustering`      | _no_     | `false`                       | Whether or not [clustering](https://grafana.com/docs/agent/latest/flow/concepts/clustering/) should be enabled                                      |

#### Labels

The following labels are automatically added to exported targets.

| Label    | Description                                                                                  |
| :------- | :------------------------------------------------------------------------------------------- |
| `source` | Constant value of `local`, denoting where the results came from, this can be useful for LBAC |

---

## Usage

### `kubernetes`

The following example will scrape all pyroscope instances in cluster.

```alloy
import.git "pyroscope" {
  repository = "https://github.com/grafana/flow-modules.git"
  revision = "main"
  path = "modules/databases/timeseries/pyroscope/metrics.alloy"
  pull_frequency = "15m"
}

// get the targets
pyroscope.kubernetes "targets" {}

// scrape the targets
pyroscope.scrape "metrics" {
  targets = pyroscope.kubernetes.targets.output
  forward_to = [
    prometheus.remote_write.default.receiver,
  ]
}

// write the metrics
prometheus.remote_write "local" {
  endpoint {
    url = "http://pyroscope:9009/api/v1/push"

    basic_auth {
      username = "example-user"
      password = "example-password"
    }
  }
}
```

### `local`

The following example will scrape pyroscope for metrics on the local machine.

```alloy
import.git "pyroscope" {
  repository = "https://github.com/grafana/flow-modules.git"
  revision = "main"
  path = "modules/databases/timeseries/pyroscope/metrics.alloy"
  pull_frequency = "15m"
}

// get the targets
pyroscope.local "targets" {}

// scrape the targets
pyroscope.scrape "metrics" {
  targets = pyroscope.local.targets.output
  forward_to = [
    prometheus.remote_write.default.receiver,
  ]
}

// write the metrics
prometheus.remote_write "default" {
  endpoint {
    url = "http://pyroscope:9009/api/v1/push"

    basic_auth {
      username = "example-user"
      password = "example-password"
    }
  }
}
```
