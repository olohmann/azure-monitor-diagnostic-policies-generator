# Azure Diagnostics Policies with Terraform

## TODO

Make notes about LA workspace scope.
Diag settings name! 

## Repository Structure Overview

This section provides an overview about the sub module structure in this repository.

1. [`./az-monitor-custom-policies-generator/`](./az-monitor-custom-policies-generator). Sources for the Azure Monitor Policies generator. The generator uses a configuration file to drive the generation of `terraform` resources for Azure Monitor policies.

1. [`./terraform/`](./terraform). Sources - partially generated, partially pre-defined - for the `terraform` based deployment of Azure Monitor Policies.

1. [`./util/`](./util). Various utility scripts. These scripts are not required for the actual deployment. They are just an addition to the dev cycle.

## End-to-End Workflow

### Process

#### First Run

```text
(optional: exec az-monitor-custom-policies-generator) -> terraform resources -> perform standard terraform deployment
```

The `terraform` deployment has a couple of convenience scripts that wrap the standard `terraform` commands (init, plan, apply, destroy) to feed the required input variables (see below) from the environment into the deployment process. All scripts are located in the [`./terraform`](./terraform) directory.

#### Changes

Re-run the policy generator and redeploy via standard `terraform` commands. `terraform` will pick up the changes accordingly.

### Required Input

The whole process requires a couple of environment variables to be configured appropriately. The set of variables is defined in [`.env.sh_template`](./.env.sh_template). In a deployment pipeline, e.g. in Azure DevOps, you would configure these variables via environment variables in the pipeline definition.

In your local development environment you can create a file `.env.sh` from the template and source it:

```sh
source ./env.sh
```

The `.env.sh` file will contain extremely sensitive information. Make sure that you don't distribute that file unintentionally. It is per default in the `.gitignore` list.

### TODOs

* Currently, the `terraform` provider requires a custom build from the master branch as the required features have not yet been released in a pre-built binary.
* This repository mixes code generation and tooling in one place. In future, this should be split.

### References

* [Terraform Azure Resource Provider Documentation](https://www.terraform.io/docs/providers/azurerm/)
* [Azure Monitor Sample Policies](https://github.com/johnkemnetz/azmon-onboarding/tree/master/policies)
