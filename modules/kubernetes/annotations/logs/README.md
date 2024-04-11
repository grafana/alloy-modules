# Kubernetes Log Annotations Module

## `logs.alloy`

Annotations offer a versatile and powerful means to tailor log ingestion and processing, adapting log management to meet particular needs
and specifications. They grant users the ability to selectively engage in specific log processing behaviors, circumventing the need for
unique configurations or customizations within the agent's setup. These annotations are accessible at the component level, allowing for
selective implementation. This ensures that only annotations relevant to the user's requirements are activated, optimizing processing
efficiency by excluding unnecessary annotations.

The following pod annotations are supported:

| Annotation                         | Type               | Component                                 | Description                                                                                                                                                                     |
| :--------------------------------- | :----------------- | :---------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `logs.grafana.com/ingest`          | Boolean String     | [pods](#pods)                             | Allow a pod to declare it's logs should be dropped, the default behavior is to ingest all logs                                                                                  |
| `logs.grafana.com/tenant`          | Regular Expression | [pods](#pods)                             | Allow a pod to override the tenant for its logs.                                                                                                                                |
| `logs.grafana.com/drop-info`       | Boolean String     | [drop_levels](#drop_levels)               | Determines if `info` logs should be dropped (default is `false`), but a pod can override this temporarily or permanently.                                                       |
| `logs.grafana.com/drop-debug`      | Boolean String     | [drop_levels](#drop_levels)               | Determines if `debug` logs should be dropped (default is `true`), but a pod can override this temporarily or permanently.                                                       |
| `logs.grafana.com/drop-trace`      | Boolean String     | [drop_levels](#drop_levels)               | Determines if `trace` logs should be dropped (default is `true`), but a pod can override this temporarily or permanently.                                                       |
| `logs.grafana.com/decolorize`      | Boolean String     | [decolorize](#decolorize)                 | Determines if [`stage.decolorized`](https://grafana.com/docs/alloy/latest/reference/components/loki.process/#stagedecolorize-block) should be used to remove escape characters. |
| `logs.grafana.com/scrub-nulls`     | Boolean String     | [json_scrub_empties](#json_scrub_empties) | Determines if keys with null values should be dropped from json, reducing the size of the log message.                                                                          |
| `logs.grafana.com/scrub-empties`   | Boolean String     | [json_scrub_nulls](#json_scrub_nulls)     | Determines if keys with empty values (`"", [], {}`) should be dropped from json, reducing the size of the log message.                                                          |
| `logs.grafana.com/embed-pod`       | Boolean String     | [embed_pod](#embed_pod)                   | Whether or not to inject the name of the pod to the end of the log message i.e. `__pod=agent-logs-grafana-agent-jrqms`.                                                         |
| `logs.grafana.com/mask-ssn`        | Boolean String     | [mask](#mask)                             | Whether or not to mask SSNs in the log line, if true the data will  be masked as `*SSN*salt*`                                                                                   |
| `logs.grafana.com/mask-email`      | Boolean String     | [mask](#mask)                             | Whether or not to mask emails in the log line, if true the data will be masked as`*email*salt*`                                                                                 |
| `logs.grafana.com/mask-ipv4`       | Boolean String     | [mask](#mask)                             | Whether or not to mask IPv4 addresses in the log line, if true the data will be masked as`*ipv4*salt*`                                                                          |
| `logs.grafana.com/mask-ipv6`       | Boolean String     | [mask](#mask)                             | Whether or not to mask IPv6 addresses in the log line, if true the data will be masked as `*ipv6*salt*`                                                                         |
| `logs.grafana.com/mask-phone`      | Boolean String     | [mask](#mask)                             | Whether or not to mask phone numbers in the log line, if true the data will be masked as `*phone*salt*`                                                                         |
| `logs.grafana.com/trim`            | Boolean String     | [trim](#trim)                             | Whether or not to trim the log line using [`strings.Trim`](https://pkg.go.dev/strings#Trim)                                                                                     |
| `logs.grafana.com/dedup-spaces`    | Boolean String     | [dedup_spaces](#dedup_spaces)             | Determines if instances of 2 or more spaces should be replaced with a single space                                                                                              |
| `logs.grafana.com/scrub-timestamp` | Boolean String     | []()                                      | whether or not the timestamp should be dropped from the log message (as it is metadata).                                                                                        |
| `logs.grafana.com/scrub-level`     | Boolean String     | []()                                      | Determines if the level should be removed from the log message (as it is a label).                                                                                              |



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
