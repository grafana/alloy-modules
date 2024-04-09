# Flow Modules

<!-- markdownlint-disable MD033 -->
<a href="https://grafana.com">
  <img height="20" src="https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white" alt="Grafana" />
</a>

<p align="center">
    <img src="assets/logo_alloy_dark.svg" alt="Grafana Alloy logo" height="100px">
</p>

**NOTE: This is only to be used for Modules not Modules Classic.**

[Modules](https://grafana.com/docs/agent/latest/flow/concepts/modules/) are a way to create Grafana Agent [Flow](https://grafana.com/docs/agent/latest/flow/) configurations which can be loaded as a component. Modules are a great way to parameterize a configuration to create reusable pipelines.

## Submitting modules

Create a folder for the module under the `./modules` directory in the appropriate category. Each module must have a `README.md` that provides the following information:

-   Components
-   Brief description
-   Applicable Agent Versions
-   Declare arguments and exports
-   Example

## Referencing Modules

Whenever a new module is submitted and a pull request is merged to the `main` branch, a tag is automatically created and published, by default this is a patch bump.

Modules can be reference directly from this git repository using the `import.git` or `import.http` components.  It is recommended to always reference a tagged version, and not the `main` branch.
