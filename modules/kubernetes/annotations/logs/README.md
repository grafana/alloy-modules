# Kubernetes Log Annotations Modules

Annotations offer a versatile and powerful means to tailor log ingestion and processing, adapting log management to meet particular needs
and specifications. They grant users the ability to selectively engage in specific log processing behaviors, circumventing the need for
unique configurations or customizations within the agent's setup. These annotations are accessible at the component level, allowing for
selective implementation. This ensures that only annotations relevant to the user's requirements are activated, optimizing processing
efficiency by excluding unnecessary annotations.

The following pod annotations are supported:

| Annotation                          | Type               | Component                                 | Description                                                                                                                                                                                                           |
| :---------------------------------- | :----------------- | :---------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `logs.grafana.com/ingest`           | Boolean String     | [pods](#pods)                             | Allow a pod to declare it's logs should be dropped, the default behavior is to ingest all logs                                                                                                                        |
| `logs.grafana.com/tenant`           | Regular Expression | [pods](#pods)                             | Allow a pod to override the tenant for its logs.                                                                                                                                                                      |
| `logs.grafana.com/drop-info`        | Boolean String     | [drop_levels](#drop_levels)               | Determines if `info` logs should be dropped (default is `false`), but a pod can override this temporarily or permanently.                                                                                             |
| `logs.grafana.com/drop-debug`       | Boolean String     | [drop_levels](#drop_levels)               | Determines if `debug` logs should be dropped (default is `true`), but a pod can override this temporarily or permanently.                                                                                             |
| `logs.grafana.com/drop-trace`       | Boolean String     | [drop_levels](#drop_levels)               | Determines if `trace` logs should be dropped (default is `true`), but a pod can override this temporarily or permanently.                                                                                             |
| `logs.grafana.com/decolorize`       | Boolean String     | [decolorize](#decolorize)                 | Determines if [`stage.decolorized`](https://grafana.com/docs/alloy/latest/reference/components/loki.process/#stagedecolorize-block) should be used to remove escape characters.                                       |
| `logs.grafana.com/scrub-nulls`      | Boolean String     | [json_scrub_empties](#json_scrub_empties) | Determines if keys with null values should be dropped from json, reducing the size of the log message.                                                                                                                |
| `logs.grafana.com/scrub-empties`    | Boolean String     | [json_scrub_nulls](#json_scrub_nulls)     | Determines if keys with empty values (`"", [], {}`) should be dropped from json, reducing the size of the log message.                                                                                                |
| `logs.grafana.com/embed-pod`        | Boolean String     | [embed_pod](#embed_pod)                   | Whether or not to inject the name of the pod to the end of the log message i.e. `__pod=agent-logs-grafana-agent-jrqms`.                                                                                               |
| `logs.grafana.com/mask-credit-card` | Boolean String     | [mask](#mask)                             | Whether or not to mask credit cards in the log line, if true the data will  be masked as `**CC*REDACTED**`                                                                                                            |
| `logs.grafana.com/mask-ssn`         | Boolean String     | [mask](#mask)                             | Whether or not to mask SSNs in the log line, if true the data will  be masked as `**SSN*REDACTED**`                                                                                                                   |
| `logs.grafana.com/mask-email`       | Boolean String     | [mask](#mask)                             | Whether or not to mask emails in the log line, if true the data will be masked as`**EMAIL*REDACTED**`                                                                                                                 |
| `logs.grafana.com/mask-ipv4`        | Boolean String     | [mask](#mask)                             | Whether or not to mask IPv4 addresses in the log line, if true the data will be masked as`**IPV4*REDACTED**`                                                                                                          |
| `logs.grafana.com/mask-ipv6`        | Boolean String     | [mask](#mask)                             | Whether or not to mask IPv6 addresses in the log line, if true the data will be masked as `**IPV6*REDACTED**`                                                                                                         |
| `logs.grafana.com/mask-phone`       | Boolean String     | [mask](#mask)                             | Whether or not to mask phone numbers in the log line, if true the data will be masked as `**PHONE*REDACTED**`                                                                                                         |
| `logs.grafana.com/mask-luhn`        | Boolean String     | [mask](#mask)                             | Whether or not to mask value which match the [Luhn Algorithm](https://en.wikipedia.org/wiki/Luhn_algorithm) in the log line, if true the data will be masked as `**LUHN*REDACTED**`                                   |
| `logs.grafana.com/trim`             | Boolean String     | [trim](#trim)                             | Whether or not to trim the log line using [`strings.Trim`](https://pkg.go.dev/strings#Trim)                                                                                                                           |
| `logs.grafana.com/dedup-spaces`     | Boolean String     | [dedup_spaces](#dedup_spaces)             | Determines if instances of 2 or more spaces should be replaced with a single space                                                                                                                                    |
| `logs.grafana.com/sample`           | Boolean String     | [sample](#sample)                         | Determines if logs from the pod should be sampled, using [`stage.sample`](https://grafana.com/docs/alloy/latest/reference/components/loki.process/#stagesampling-block), at a given rate between 0-1 (.25) by default |

---

## `logs.alloy`

### `pods`

---

## `drop.alloy`

### `drop_levels`

Handles the dropping of log messages based on a determined log level. This can help reduce the overall number of log messages/volume while still allowing applications to log verbose messages. The following annotations are supported:

-   `logs.grafana.com/drop-trace`
-   `logs.grafana.com/drop-debug`
-   `logs.grafana.com/drop-info`

#### Arguments

| Name          | Required | Default               | Description                                                                                                                                                                          |
| :------------ | :------- | :-------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`  | _yes_    | `list(LogsReceiver)`  | Must be a where scraped should be forwarded to                                                                                                                                       |
| `annotation`  | _no_     | `logs.grafana.com`    | The annotation namespace to use                                                                                                                                                      |
| `trace_value` | _no_     | `"true"`              | The regular expression to use to determine if trace logs should be dropped, if you want to drop trace by default without setting the annotations everywhere use `".*"` or `"true\|"` |
| `trace_level` | _no_     | `"(?i)(trace?\|trc)"` | The regular expression to use to match trace logs level label value                                                                                                                  |
| `debug_value` | _no_     | `"true"`              | The regular expression to use to determine if debug logs should be dropped, if you want to drop debug by default without setting the annotations everywhere use `".*"` or `"true\|"` |
| `debug_level` | _no_     | `(?i)(debug?\|dbg)`   | The regular expression to use to match debug logs level label value                                                                                                                  |
| `info_value`  | _no_     | `"true"`              | The regular expression to use to determine if info logs should be dropped, if you want to drop info by default without setting the annotations everywhere use `".*"` or `"true\|"`   |
| `info_level`  | _no_     | `(?i)(info?)`         | The regular expression to use to match info logs level label value                                                                                                                   |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

---

## `embed.alloy`

### `embed_pod`

Loki supports [Structured Metadata](https://grafana.com/docs/loki/latest/get-started/labels/structured-metadata/) which is the ideal solution to embedding information without adding additional labels.  However, if this is not possible then the next best solution is to embed the name of the pod at the end of the log line.  The module accounts for json or raw text, and supports the following annotation:

-   `logs.grafana.com/embed-pod`

#### Arguments

| Name              | Required | Default              | Description                                                                                                                                                                              |
| :---------------- | :------- | :------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`      | _yes_    | `list(LogsReceiver)` | Must be a where scraped should be forwarded to                                                                                                                                           |
| `annotation`      | _no_     | `logs.grafana.com`   | The annotation namespace to use                                                                                                                                                          |
| `embed_pod_value` | _no_     | `"true"`             | The regular expression to use to determine if pod should be embedded or not, if you want to embed the pod by default without setting the annotations everywhere use `".*"` or `"true\|"` |
| `embed_pod_key`   | _no_     | `"__pod"`            | The key to use to embed the pod name into the log message                                                                                                                                |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

---

## `json.alloy`

### `json_scrub_empties`

JSON is great because it offers a flexible storage schema, where the "schema" is stored next to the value. However, this flexibility comes at a cost; JSON is not an efficient storage mechanism because the "schema" is repeatedly stored next to each value. This can lead to unnecessary and extra bytes, especially when values are empty or defaulted, such as an empty string `""`, an empty object `{}`, or an empty array `[]`. When a value is empty, both the property and the value can be
removed to optimize storage. The following annotation supports this functionality:

-   `logs.grafana.com/scrub-empties`

#### Arguments

| Name                  | Required | Default              | Description                                                                                                                                                                                       |
| :-------------------- | :------- | :------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `forward_to`          | _yes_    | `list(LogsReceiver)` | Must be a where scraped should be forwarded to                                                                                                                                                    |
| `annotation`          | _no_     | `logs.grafana.com`   | The annotation namespace to use                                                                                                                                                                   |
| `scrub_empties_value` | _no_     | `"true"`             | The regular expression to use to determine if logs should have json empties scrubbed, if you want to scrub empties by default without setting the annotations everywhere use `".*"` or `"true\|"` |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

### `json_scrub_nulls`

Similar to `scrub-empties`, scrubbing `null` values from JSON logs can be beneficial for the same reasons, offering similar cost benefits. Removing `null` values can help reduce the storage size by eliminating unnecessary JSON entries. The following annotation supports this optimization:

-   `logs.grafana.com/scrub-nulls`

#### Arguments

| Name                | Required | Default              | Description                                                                                                                                                                                   |
| :------------------ | :------- | :------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`        | _yes_    | `list(LogsReceiver)` | Must be a where scraped should be forwarded to                                                                                                                                                |
| `annotation`        | _no_     | `logs.grafana.com`   | The annotation namespace to use                                                                                                                                                               |
| `scrub_nulls_value` | _no_     | `"true"`             | The regular expression to use to determine if logs should have json nulls scrubbed, if you want to scrub nulls by default without setting the annotations everywhere use `".*"` or `"true\|"` |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

---

## `mask.alloy`

### `mask_luhn`

Supports detecting and masking strings within log lines that match the [Luhn Algorithm](https://en.wikipedia.org/wiki/Luhn_algorithm).

-   `logs.grafana.com/mask-luhn`

#### Arguments

| Name              | Required | Default               | Description                                                                                                                                                                                |
| :---------------- | :------- | :-------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`      | _yes_    | `list(LogsReceiver)`  | Must be a where scraped should be forwarded to                                                                                                                                             |
| `annotation`      | _no_     | `logs.grafana.com`    | The annotation namespace to use                                                                                                                                                            |
| `mask_luhn_value` | _no_     | `"(?i)true"`          | The regular expression to use to determine if logs should have luhn values masked, if you want to mask luhn by default without setting the annotations everywhere use `".*"` or `"true\|"` |
| `min_length`      | _no_     | `13`                  | The minimum length of a Luhn match to mask                                                                                                                                                 |
| `replace_text`    | _no_     | `"**LUHN*REDACTED**"` | The replacement text to use to for Luhn matches                                                                                                                                            |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

### `mask_credit_card`

Supports detecting and masking strings within log lines that match various credit card formats.

-   `logs.grafana.com/mask-credit-card`

#### Arguments

| Name                     | Required | Default              | Description                                                                                                                                                                                               |
| :----------------------- | :------- | :------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`             | _yes_    | `list(LogsReceiver)` | Must be a where scraped should be forwarded to                                                                                                                                                            |
| `annotation`             | _no_     | `logs.grafana.com`   | The annotation namespace to use                                                                                                                                                                           |
| `mask_credit_card_value` | _no_     | `"(?i)true"`         | The regular expression to use to determine if logs should have credit card values masked, if you want to mask credit cards by default without setting the annotations everywhere use `".*"` or `"true\|"` |
| `replace_text`           | _no_     | `"**CC*REDACTED**"`  | The replacement text to use to for Credit Card matches                                                                                                                                                    |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

### `mask_email`

Supports detecting and masking strings within log lines that match various email formats.

-   `logs.grafana.com/mask-email`

#### Arguments

| Name               | Required | Default                | Description                                                                                                                                                                             |
| :----------------- | :------- | :--------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`       | _yes_    | `list(LogsReceiver)`   | Must be a where scraped should be forwarded to                                                                                                                                          |
| `annotation`       | _no_     | `logs.grafana.com`     | The annotation namespace to use                                                                                                                                                         |
| `mask_email_value` | _no_     | `"(?i)true"`           | The regular expression to use to determine if logs should have emails masked, if you want to mask emails by default without setting the annotations everywhere use `".*"` or `"true\|"` |
| `replace_text`     | _no_     | `"**EMAIL*REDACTED**"` | The replacement text to use to for Credit Card matches                                                                                                                                  |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

### `mask_ipv4`

Supports detecting and masking strings within log lines that match IPv4 formats.

-   `logs.grafana.com/mask-ipv4`

#### Arguments

| Name              | Required | Default               | Description                                                                                                                                                                                       |
| :---------------- | :------- | :-------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `forward_to`      | _yes_    | `list(LogsReceiver)`  | Must be a where scraped should be forwarded to                                                                                                                                                    |
| `annotation`      | _no_     | `logs.grafana.com`    | The annotation namespace to use                                                                                                                                                                   |
| `mask_ipv4_value` | _no_     | `"(?i)true"`          | The regular expression to use to determine if logs should have IPv4 values masked, if you want to mask IPv4 values by default without setting the annotations everywhere use `".*"` or `"true\|"` |
| `replace_text`    | _no_     | `"**IPv4*REDACTED**"` | The replacement text to use to for Credit Card matches                                                                                                                                            |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

### `mask_ipv6`

Supports detecting and masking strings within log lines that match IPv6 formats.

-   `logs.grafana.com/mask-ipv6`

#### Arguments

| Name              | Required | Default               | Description                                                                                                                                                                                       |
| :---------------- | :------- | :-------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `forward_to`      | _yes_    | `list(LogsReceiver)`  | Must be a where scraped should be forwarded to                                                                                                                                                    |
| `annotation`      | _no_     | `logs.grafana.com`    | The annotation namespace to use                                                                                                                                                                   |
| `mask_ipv6_value` | _no_     | `"(?i)true"`          | The regular expression to use to determine if logs should have IPv6 values masked, if you want to mask IPv6 values by default without setting the annotations everywhere use `".*"` or `"true\|"` |
| `replace_text`    | _no_     | `"**IPv6*REDACTED**"` | The replacement text to use to for Credit Card matches                                                                                                                                            |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

### `mask_phone`

Supports detecting and masking strings within log lines that match phone number formats.

-   `logs.grafana.com/mask-phone`

#### Arguments

| Name               | Required | Default                | Description                                                                                                                                                                                           |
| :----------------- | :------- | :--------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`       | _yes_    | `list(LogsReceiver)`   | Must be a where scraped should be forwarded to                                                                                                                                                        |
| `annotation`       | _no_     | `logs.grafana.com`     | The annotation namespace to use                                                                                                                                                                       |
| `mask_phone_value` | _no_     | `"(?i)true"`           | The regular expression to use to determine if logs should have phone numbers masked, if you want to mask phone numbers by default without setting the annotations everywhere use `".*"` or `"true\|"` |
| `replace_text`     | _no_     | `"**PHONE*REDACTED**"` | The replacement text to use to for Credit Card matches                                                                                                                                                |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

### `mask_ssn`

Supports detecting and masking strings within log lines that match social security number formats.

-   `logs.grafana.com/mask-ssn`

#### Arguments

| Name             | Required | Default              | Description                                                                                                                                                                         |
| :--------------- | :------- | :------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`     | _yes_    | `list(LogsReceiver)` | Must be a where scraped should be forwarded to                                                                                                                                      |
| `annotation`     | _no_     | `logs.grafana.com`   | The annotation namespace to use                                                                                                                                                     |
| `mask_ssn_value` | _no_     | `"(?i)true"`         | The regular expression to use to determine if logs should have SSNs masked, if you want to mask SSNs by default without setting the annotations everywhere use `".*"` or `"true\|"` |
| `replace_text`   | _no_     | `"**SSN*REDACTED**"` | The replacement text to use to for SSN matches                                                                                                                                      |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

---

## `utils.alloy`

### `decolorize`

Supports the removal of ANSI color codes from the log lines, thus making it easier to parse logs and reducing bytes.

-   `logs.grafana.com/decolorize`

#### Arguments

| Name               | Required | Default              | Description                                                                                                                                                                        |
| :----------------- | :------- | :------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`       | _yes_    | `list(LogsReceiver)` | Must be a where scraped should be forwarded to                                                                                                                                     |
| `annotation`       | _no_     | `logs.grafana.com`   | The annotation namespace to use                                                                                                                                                    |
| `decolorize_value` | _no_     | `"(?i)true"`         | The regular expression to use to determine if logs should be decolorized, if you want to decolorize by default without setting the annotations everywhere use `".*"` or `"true\|"` |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

### `trim`

Supports the removal of any leading or trailing whitespace from the log lines.

-   `logs.grafana.com/trim`

#### Arguments

| Name         | Required | Default              | Description                                                                                                                                                                                     |
| :----------- | :------- | :------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to` | _yes_    | `list(LogsReceiver)` | Must be a where scraped should be forwarded to                                                                                                                                                  |
| `annotation` | _no_     | `logs.grafana.com`   | The annotation namespace to use                                                                                                                                                                 |
| `trim_value` | _no_     | `"(?i)true"`         | The regular expression to use to determine if whitespace should be embedded or not, if you want to embed the pod by default without setting the annotations everywhere use `".*"` or `"true\|"` |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

### `dedup_spaces`

Supports replacing two or more spaces with a single space.

-   `logs.grafana.com/trim`

#### Arguments

| Name         | Required | Default              | Description                                                                                                                                                       |
| :----------- | :------- | :------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to` | _yes_    | `list(LogsReceiver)` | Must be a where scraped should be forwarded to                                                                                                                    |
| `annotation` | _no_     | `logs.grafana.com`   | The annotation namespace to use                                                                                                                                   |
| `trim_value` | _no_     | `"(?i)true"`         | The regular expression to use to determine if multiple spaces should be replaced with a single space or not, if you want to always dedup use `".*"` or `"true\|"` |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

### `sampling`

Supports sampling of logs at a given rate

-   `logs.grafana.com/sampling`

#### Arguments

| Name              | Required | Default               | Description                                                                                                                                                       |
| :---------------- | :------- | :-------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `forward_to`      | _yes_    | `list(LogsReceiver)`  | Must be a where scraped should be forwarded to                                                                                                                    |
| `annotation`      | _no_     | `logs.grafana.com`    | The annotation namespace to use                                                                                                                                   |
| `sampling_value`  | _no_     | `"(?i)true"`          | The regular expression to use to determine if multiple spaces should be replaced with a single space or not, if you want to always dedup use `".*"` or `"true\|"` |
| `sampling_rate`   | _no_     | `0.25`                | The sampling rate in a range of [0, 1]                                                                                                                            |
| `sampling_reason` | _no_     | `annotation_sampling` | The sampling reason                                                                                                                                               |

#### Exports

| Name         | Type           | Description                                     |
| :----------- | :------------- | :---------------------------------------------- |
| `annotation` | `string`       | The value passed into the `annotation` argument |
| `receiver`   | `LogsReceiver` | The `loki.process` receiver for the module      |

---

## Usage

```alloy
import.git "log_utils" {
  repository = "https://github.com/grafana/alloy-modules.git"
  revision   = "main"
  path       = "modules/utils/logs/"
}

import.git "k8s_logs" {
  repository = "https://github.com/grafana/alloy-modules.git"
  revision   = "main"
  path       = "modules/kubernetes/core/logs.alloy"
}

import.git "log_annotations" {
  repository = "https://github.com/grafana/alloy-modules.git"
  revision   = "main"
  path       = "modules/kubernetes/annotations/logs.alloy"
}

log_annotations.pods "targets" {
  annotation = "logs.grafana.com"
}

k8s_logs.from_worker "default" {
  targets = log_annotations.pods.targets.output
  forward_to = [log_annotations.decolorize.default.receiver]
}

log_annotations.decolorize "default" {
  forward_to = [log_utils.default_level.default.receiver]
  annotation = "logs.grafana.com"
}

log_utils.default_level "default" {
  forward_to = [log_utils.normalize_level.default.receiver]
}

log_utils.normalize_level "default" {
  forward_to = [
    log_utils.pre_process_metrics.default.receiver,
    log_annotations.drop_levels.default.receiver,
  ]
}

log_utils.pre_process_metrics "default" {}

log_annotations.drop_levels "default" {
  forward_to = [log_annotations.mask.default.receiver]
  annotation = "logs.agent.grafana.com"
}

log_annotations.mask "default" {
  forward_to = [log_annotations.trim.default.receiver]
  annotation = "logs.agent.grafana.com"
}

log_annotations.trim "default" {
  forward_to = [log_annotations.dedup_spaces.default.receiver]
  annotation = "logs.agent.grafana.com"
}

log_annotations.dedup_spaces "default" {
  forward_to = [log_utils.structured_metadata.default.receiver]
  annotation = "logs.agent.grafana.com"
}

log_utils.structured_metadata "default" {
  forward_to = [log_utils.keep_labels.default.receiver]
}

log_utils.keep_labels "default" {
  forward_to = [
    log_utils.post_process_metrics.default.receiver,
    loki.write.local.receiver,
  ]
}

log_utils.post_process_metrics "default" {}

loki.write "local" {
  endpoint {
    url = env("LOGS_PRIMARY_URL")

    basic_auth {
      username = env("LOGS_PRIMARY_TENANT")
      password = env("LOGS_PRIMARY_TOKEN")
    }
  }

  external_labels = {
    "cluster" = coalesce(env("CLUSTER_NAME"), env("CLUSTER"), ""),
    "env" = coalesce(env("ENV"), ""),
    "region" = coalesce(env("REGION"), ""),
  }
}
```
