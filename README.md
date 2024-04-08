# Flow Modules

<p align="center"><img src="assets/logo_and_name.png" alt="Grafana Agent logo"></p>

**NOTE: This is only to be used for Modules not Modules Classic.**

[Modules](https://grafana.com/docs/agent/latest/flow/concepts/modules/) are a way to create Grafana Agent [Flow](https://grafana.com/docs/agent/latest/flow/) configurations which can be loaded as a component. Modules are a great way to parameterize a configuration to create reusable pipelines.

## Contents

-   **modules**: A library of usable modules out of the box
-   **example**: A practical example shown for each module loader plus without modules for comparison
-   **util**: Utilities for managing modules in this repo

## Modules

| Name |  Description | Agent Version |
| ---- |  ----------- | ------------- |

## Submitting modules

Add modules to the `modules` folder. Each module must have a README.MD that provides the following information:
* Name
* Brief description
* Applicable Agent Versions
* Declare arguments and exports
* Example
