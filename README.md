# Azure Diagnostics Policies with Terraform

This repository provides a very simple Python tool that generates Terraform-based Azure Policy definitions and definition sets. It is an alternative to use ARM templates as defined [here](https://github.com/johnkemnetz/azmon-onboarding/tree/master/policies). Terraform provides a little more flexibility to track policy changes and to validate the current state. In addition, you can use the policy generator to create multiple flavors of the Policy Definitions. For example, one config set that is driving central IT policies (focus on audit & security), and another config set that is full fledged (all data including metrics) for the actual DevOps crew running a service.

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

* This repository mixes code generation and tooling in one place. In future, this should be split.
* Document the LA workspace scope.

### References

* [Terraform Azure Resource Provider Documentation](https://www.terraform.io/docs/providers/azurerm/)
* [Azure Monitor Sample Policies](https://github.com/johnkemnetz/azmon-onboarding/tree/master/policies)
