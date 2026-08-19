# SolarEdge Module

Scrapes SolarEdge inverter metrics exposed by a local Prometheus exporter that polls the
inverter over Modbus TCP using the SunSpec protocol (for example
[dave92082/SolarEdge-Exporter](https://github.com/dave92082/SolarEdge-Exporter)).

This module does **not** speak Modbus itself. Run an exporter sidecar that connects to the
inverter on TCP port `502` (LCD default) or `1502` (SetApp default), then point
[Grafana Alloy](https://github.com/grafana/alloy) at the exporter's `/metrics` endpoint
(default `:2112`).

## Applicable Alloy versions

[Grafana Alloy](https://github.com/grafana/alloy) v1.0 and later (uses `import.git`,
`discovery.relabel`, `prometheus.scrape`, and `prometheus.relabel`).

## Prerequisites

See the exporter's upstream
[Requirements](https://github.com/dave92082/SolarEdge-Exporter/#requirements)
for the canonical checklist. In short:

- SolarEdge inverter with SunSpec support (SetApp models, or LCD firmware CPU `3.xxxx`+)
- Modbus TCP enabled on the inverter
- Ethernet / LAN path to the inverter (not ZigBee or GSM)
- Only **one** Modbus TCP client may connect at a time
- Cloud SolarEdge monitoring and local Modbus TCP can run in parallel

## Components

- [`local`](#local)
- [`scrape`](#scrape)

### `local`

Builds a static scrape target for a SolarEdge Prometheus exporter.

#### Arguments

| Name                | Optional | Default          | Description                                    |
| :------------------ | :------- | :--------------- | :--------------------------------------------- |
| `exporter_address`  | `true`   | `127.0.0.1:2112` | Host:port of the SolarEdge Prometheus exporter |

#### Exports

| Name     | Type                | Description                |
| :------- | :------------------ | :------------------------- |
| `output` | `list(map(string))` | List of discovered targets |

#### Labels

The following labels are automatically added to exported targets.

| Label    | Description                                                                |
| :------- | :------------------------------------------------------------------------- |
| `source` | Constant value of `local`, denoting where the results came from (for LBAC) |

---

### `scrape`

Scrapes SolarEdge exporter targets and keep-lists inverter SunSpec metrics.

#### Arguments

| Name                | Required | Default                                                   | Description                                                              |
| :------------------ | :------- | :-------------------------------------------------------- | :----------------------------------------------------------------------- |
| `targets`           | _yes_    |                                                           | List of targets to scrape                                                |
| `forward_to`        | _yes_    |                                                           | List of `MetricsReceiver` where scraped samples are forwarded            |
| `job_label`         | _no_     | `integrations/solaredge`                                  | Job label for scraped metrics                                            |
| `keep_metrics`      | _no_     | [see code](metrics.alloy#L119)                            | Regex of metrics to keep (inverter series + `up`; meters excluded in v1) |
| `drop_metrics`      | _no_     | [see code](metrics.alloy#L111)                            | Regex of metrics to drop                                                 |
| `scheme`            | _no_     | `http`                                                    | Scrape scheme                                                            |
| `bearer_token_file` | _no_     | none                                                      | Optional bearer token file                                               |
| `scrape_interval`   | _no_     | `15s`                                                     | How often to scrape                                                      |
| `scrape_timeout`    | _no_     | `10s`                                                     | Scrape timeout                                                           |
| `max_cache_size`    | _no_     | `100000`                                                  | Relabel cache size                                                       |
| `clustering`        | _no_     | `false`                                                   | Enable Alloy clustering for this scrape                                  |

#### Labels

The following labels are automatically added to scraped metrics.

| Label | Description                                    |
| :---- | :--------------------------------------------- |
| `job` | Set to the value of `argument.job_label.value` |

---

## Usage

Pin a tagged revision of [grafana/alloy-modules](https://github.com/grafana/alloy-modules)
(not `main`). Alloy needs network egress to `github.com` for `import.git`.

```alloy
import.git "solaredge" {
  repository     = "https://github.com/grafana/alloy-modules.git"
  revision       = "v0.2.12" // pin a release tag that includes this module
  path           = "modules/system/solaredge/metrics.alloy"
  pull_frequency = "15m"
}

solaredge.local "home" {
  exporter_address = "127.0.0.1:2112"
}

solaredge.scrape "inverter" {
  targets    = solaredge.local.home.output
  forward_to = [prometheus.remote_write.metrics.receiver]
}

prometheus.remote_write "metrics" {
  endpoint {
    url = "http://mimir:9009/api/v1/push"
  }
}
```

### Local development with `import.file`

From a clone of [grafana/alloy-modules](https://github.com/grafana/alloy-modules):

```alloy
import.file "solaredge" {
  filename = "./modules/system/solaredge/metrics.alloy"
}

solaredge.local "home" {
  exporter_address = "127.0.0.1:2112"
}

solaredge.scrape "inverter" {
  targets    = solaredge.local.home.output
  forward_to = [prometheus.remote_write.metrics.receiver]
}
```

## Sample PromQL

```promql
up{job="integrations/solaredge"}
AC_Power
DC_Power
Status
SunSpec_DID
```

## Next steps

v1 keep-lists **inverter** SunSpec metrics only. Planned follow-ups:

1. **Meters** — include `M_*`, `M2_*`, `M3_*` (export / import energy) when `NumMeters` ≥ 1 on
   [dave92082/SolarEdge-Exporter](https://github.com/dave92082/SolarEdge-Exporter)
2. **Batteries** — StorEdge / BYD registers when an exporter exposes them

A runnable end-to-end demo lives in
[grafana/alloy-scenarios](https://github.com/grafana/alloy-scenarios)
under `solaredge-monitoring/`.

## Notes

- Do not run a second Modbus client (Home Assistant, another logger) against the same inverter
  while the exporter holds the session.
- Upstream exporter requirements:
  [Requirements](https://github.com/dave92082/SolarEdge-Exporter/#requirements)
