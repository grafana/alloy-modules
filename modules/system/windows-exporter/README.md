# Windows Exporter Module

Handles scraping Windows Exporter metrics.

## Components

-   [`local`](#local)
-   [`scrape`](#scrape)

### `local`

#### Arguments

| Name                       | Optional     | Default                                                                                             | Description                            |
| :-----                     | :-------     | :------                                                                                             | :------------------------------------- |
| `collectors`               | `true`       | `["cpu", "cs", "logical_disk", "net", "os", "service", "system", "textfile", "time", "diskdrive"]`  | The of the port to scrape metrics from |
| `timeout`                  | `true`       | `4m`                                                                                                | Timeout for collecting metrics         |
| `textfile_directory`       | `true`       | `C:\Program Files\GrafanaLabs\Alloy\textfile_imports`                                               | The directory containing files to be ingested |
| `iis_app_exclude`          | `true`       | `""`                                                                                                | Regular Expression of applications to ignore |
| `iis_app_include`          | `true`       | `".*"`                                                                                              | Regular Expression of applications to report on |
| `iis_site_exclude`         | `true`       | `""`                                                                                                | Regular Expression of sites to ignore |
| `iis_site_include`         | `true`       | `".*"`                                                                                              | Regular Expression of sites to report on |
| `logical_disk_exclude`     | `true`       | `""`                                                                                                | Regular Expression of volumes to exclude |
| `logical_disk_include`     | `true`       | `".+"`                                                                                              | Regular Expression of volumes to include |
| `process_exclude`          | `true`       | `""`                                                                                                | Regular Expression of processes to exclude |
| `process_include`          | `true`       | `".*"`                                                                                              | Regular Expression of processes to include |
| `service_wql_where_clause` | `true`       | `".*"`                                                                                              | WQL 'where' clause to use in WMI metrics query.|

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
| `job_label`       | _no_     | `integrations/node_exporter`  | The job label to add for all mimir metric                                                                                                           |
| `keep_metrics`    | _no_     | [see code](module.river#L228) | A regular expression of metrics to keep                                                                                                             |
| `drop_metrics`    | _no_     | [see code](module.river#L235) | A regular expression of metrics to drop                                                                                                             |
| `scrape_interval` | _no_     | `60s`                         | How often to scrape metrics from the targets                                                                                                        |
| `scrape_timeout`  | _no_     | `10s`                         | How long before a scrape times out                                                                                                                  |
| `max_cache_size`  | _no_     | `100000`                      | The maximum number of elements to hold in the relabeling cache.  This should be at least 2x-5x your largest scrape target or samples appended rate. |
| `clustering`      | _no_     | `false`                       | Whether or not [clustering](https://node_exporter.com/docs/agent/latest/flow/concepts/clustering/) should be enabled                                |

#### Labels

The following labels are automatically added to exported targets.

| Label | Description                                    |
| :---- | :--------------------------------------------- |
| `job` | Set to the value of `argument.job_label.value` |

---

## Usage

### `local`

The following example will scrape node_exporter for metrics on the local machine.

```river
import.git "node_exporter" {
  repository = "https://github.com/node_exporter/agent-modules.git"
  revision = "main"
  path = "modules/system/node-exporter/metrics.river"
  pull_frequency = "15m"
}

// get the targets
node_exporter.local "targets" {}

// scrape the targets
node_exporter.scrape "metrics" {
  targets = node_exporter.local.targets.output
  forward_to = [
    prometheus.remote_write.default.receiver,
  ]
}

// write the metrics
prometheus.remote_write "default" {
  endpoint {
    url = "http://mimir:9009/api/v1/push"

    basic_auth {
      username = "example-user"
      password = "example-password"
    }
  }
}
```
