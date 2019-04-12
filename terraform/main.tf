provider "azurerm" {
  version = ">=1.21.0"
}

module "az_monitor_custom_policies_generated" {
  source                    = "./az-monitor-custom-policies-generated"
  custom_policies_prefix    = "${var.custom_policies_prefix}"
  initiative_name           = "${var.custom_policies_prefix}_DIAG_0000_Initiative"
  deployment_version        = "${var.deployment_version}"
  management_group_id       = "${var.management_group_id}"
}

resource "azurerm_policy_assignment" "initiative_assignment" {
  name                 = "${var.custom_policies_prefix}_DIAG_0000"
  display_name         = "${var.custom_policies_prefix}_DIAG_0000_Initiative_Assignment"
  scope                = "${var.scope}"
  policy_definition_id = "${module.az_monitor_custom_policies_generated.policy_set_id}"
  description          = "${var.custom_policies_prefix}_DIAG_0000_Initiative_Assignment ${var.deployment_version}"
  identity {
    type = "SystemAssigned"
  }

  location = "${var.location}"

  parameters = <<PARAMETERS
{
  "diagSettingsName": {
    "value": "${var.diagnostics_settings_name}"
  },
  "logAnalytics": {
    "value": "${var.log_analytics_workspace_id}"
  }
}
PARAMETERS
}

resource "azurerm_role_assignment" "initiative_assignment_rbac_monitoring_contributor" {
  scope                = "${var.scope}"
  role_definition_name = "Monitoring Contributor"
  principal_id         = "${azurerm_policy_assignment.initiative_assignment.identity.0.principal_id}"
}

resource "azurerm_role_assignment" "initiative_assignment_rbac_log_analytics_contributor" {
  scope                = "${var.scope}"
  role_definition_name = "Log Analytics Contributor"
  principal_id         = "${azurerm_policy_assignment.initiative_assignment.identity.0.principal_id}"
}
