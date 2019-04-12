resource "azurerm_policy_set_definition" "initiative" {
  name                = "${var.initiative_name}"
  policy_type         = "Custom"
  display_name        = "${var.initiative_name}"
  description         = "${var.initiative_name} ${var.deployment_version}"
  management_group_id = "${var.management_group_id}"
  parameters          = <<PARAMETERS
{
    "diagSettingsName": {
        "metadata": {
            "displayName": "Diagnostic Settings Name",
            "description": "Diagnostic Settings Name. Must be unique per resource."
        },
        "type": "String"
    },
    "logAnalytics": {
        "metadata": {
            "displayName": "Log Analytics Workspace",
            "description": "Select the Log Analytics workspace from dropdown list",
            "strongType": "omsWorkspace"
        },
        "type": "String"
    }
}
PARAMETERS

  policy_definitions = <<POLICY_DEFINITIONS
    [
{% for policyDefinitionId in policyDefinitionIds %}
    {
        "parameters": {
          "diagSettingsName": {
            "value": "[parameters('diagSettingsName')]"
          },
          "logAnalytics": {
            "value": "[parameters('logAnalytics')]"
          }
        },
        "policyDefinitionId": "{{policyDefinitionId}}"
    }{{ "," if not loop.last }}
{% endfor %} 
    ]
POLICY_DEFINITIONS
}

output "policy_set_id" {
  value = "${azurerm_policy_set_definition.initiative.id}"
}
