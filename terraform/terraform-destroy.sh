#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

terraform destroy \
  -var "custom_policies_prefix=${custom_policies_prefix}" \
  -var "deployment_version=${deployment_version}" \
  -var "log_analytics_workspace_id=${log_analytics_workspace_id}" \
  -var "diagnostics_settings_name=${diagnostics_settings_name}" \
  -var "scope=${scope}" \
  -var "location=${location}" \
  -var "management_group_id=${management_group_id}" \
  -input=false \
  -auto-approve
