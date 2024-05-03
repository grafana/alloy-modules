# Grafana Cloud Auto-Configuration Module

> [!WARNING]
> Currently, the Pyroscope functionality in this module is under the `public-preview` stability level. As such, to use this module, you will need to pass `--stability.level=public-preview` to your `alloy run` command.
>
> See the docs for [`pyroscope.write`](https://grafana.com/docs/alloy/latest/reference/components/pyroscope.write/) and [Grafana Labs' Release Lifecycle](https://grafana.com/docs/release-life-cycle/) for more info on this.

Module to interact with Grafana Cloud.

## Components

-   [`stack`](#stack)

### `stack`

Module to automatically configure receivers for Grafana Cloud.

To create a token:

1.  Navigate to the [Grafana Cloud Portal](https://grafana.com/profile/org)
2.  Go to either the `Access Policies` or `API Keys` page, located in the `Security` section
3.  Create an Access Policy or API token with the correct permissions

The token must have permissions to read stack information. The setup of these permissions depends on the type of token:

-   Access Policies need the `stacks:read` scope
-   API Keys need at least the the `MetricsPublisher` role

#### Arguments

| Name         | Required | Default | Description                                        |
| :----------- | :------- | :------ | :------------------------------------------------- |
| `stack_name` | _yes_    | `N/A`   | Name of your stack as shown in the account console |
| `token`      | _yes_    | `N/A`   | Access policy token or API Key.                    |

#### Exports

| Name       | Type                     | Description                                                                                                                  |
| ---------- | ------------------------ | ---------------------------------------------------------------------------------------------------------------------------- |
| `metrics`  | `prometheus.Interceptor` | A value that other components can use to send metrics data to.                                                               |
| `logs`     | `loki.LogsReceiver`      | A value that other components can use to send logs data to.                                                                  |
| `traces`   | `otelcol.Consumer`       | A value that other components can use to send trace data to.                                                                 |
| `profiles` | `write.fanOutClient`     | A value that other components can use to send profiling data to.                                                             |
| `info`     | `object`                 | Decoded representation of the [Stack info endpoint](https://grafana.com/docs/grafana-cloud/api-reference/cloud-api/#stacks). |

---

## Usage

### `stack`

```river
import.git "grafana_cloud" {
  repository = "https://github.com/grafana/alloy-modules.git"
  revision = "main"
  path = "modules/cloud/grafana/cloud/module.alloy"
  pull_frequency = "15m"
}

// get the receivers
grafana_cloud.stack "receivers" {
  stack_name = "DashyMcDashFace"
  token = "XXXXXXXXXXXXX"
}

// scrape metrics and write to grafana cloud
prometheus.scrape "default" {
  targets = [
    {"__address__" = "127.0.0.1:12345"},
  ]
  forward_to = [
    grafana_cloud.stack.receivers.metrics,
  ]
}
```
