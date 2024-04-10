# kube-state-metrics Module

Handles scraping Grafana kube-state-metrics metrics.

## Components

-   [`kubernetes`](#kubernetes)
-   [`scrape`](#scrape)

### `kubernetes`

Handles discovery of kubernetes targets and exports them, this component does not perform any scraping at all and is not required to be used for kubernetes, as a custom service discovery and targets can be defined and passed to `kube-state-metrics.scrape`

#### Arguments

| Name         | Required | Default                                         | Description                                                                 |
| :----------- | :------- | :---------------------------------------------- | :-------------------------------------------------------------------------- |
| `namespaces` | _no_     | `[]`                                            | The namespaces to look for targets in, the default (`[]`) is all namespaces |
| `selectors`  | _no_     | `["app.kubernetes.io/name=kube-state-metrics"]` | The label selectors to use to find matching targets                         |
| `port_name`  | _no_     | `http-metrics`                                  | The of the port to scrape metrics from                                      |

#### Exports

| Name     | Type                | Description                |
| :------- | :------------------ | :------------------------- |
| `output` | `list(map(string))` | List of discovered targets |

#### Labels

The following labels are automatically added to exported targets.

| Label     | Description                                                                                                                   |
| :-------- | :---------------------------------------------------------------------------------------------------------------------------- |
| `service` | The name of the service the endpoint/pod is associated with, derived from the metadata label `__meta_kubernetes_service_name` |
| `source`  | Constant value of `kubernetes`, denoting where the results came from, this can be useful for LBAC                             |

---

### `scrape`

#### Arguments

| Name              | Required | Default                                      | Description                                                                                                                                         |
| :---------------- | :------- | :------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------- |
| `targets`         | _yes_    | `list(map(string))`                          | List of targets to scrape                                                                                                                           |
| `forward_to`      | _yes_    | `list(MetricsReceiver)`                      | Must be a where scraped should be forwarded to                                                                                                      |
| `job_label`       | _no_     | `integrations/kubernetes/kube-state-metrics` | The job label to add for all metrics                                                                                                                |
| `keep_metrics`    | _no_     | [see code](module.river#L228)                | A regular expression of metrics to keep                                                                                                             |
| `drop_metrics`    | _no_     | [see code](module.river#L235)                | A regular expression of metrics to drop                                                                                                             |
| `scrape_interval` | _no_     | `60s`                                        | How often to scrape metrics from the targets                                                                                                        |
| `scrape_timeout`  | _no_     | `10s`                                        | How long before a scrape times out                                                                                                                  |
| `max_cache_size`  | _no_     | `100000`                                     | The maximum number of elements to hold in the relabeling cache.  This should be at least 2x-5x your largest scrape target or samples appended rate. |
| `clustering`      | _no_     | `false`                                      | Whether or not [clustering](https://grafana.com/docs/kube-state-metrics/latest/flow/concepts/clustering/) should be enabled                         |

#### Labels

The following labels are automatically added to exported targets.

| Label | Description                                    |
| :---- | :--------------------------------------------- |
| `job` | Set to the value of `argument.job_label.value` |

---

## Usage

The following example will scrape all kube-state-metrics in cluster.

```river
import.git "ksm" {
  repository = "https://github.com/grafana/ksm-modules.git"
  revision = "main"
  path = "modules/kubernetes/kube-state-metrics/metrics.alloy"
  pull_frequency = "15m"
}

// get the targets
ksm.kubernetes "targets" {}

// scrape the targets
ksm.scrape "metrics" {
  targets = ksm.kubernetes.targets.output
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
