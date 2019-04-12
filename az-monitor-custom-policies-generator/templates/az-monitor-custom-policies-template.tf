resource "azurerm_policy_definition" "policy_{{policyPartialName}}" {
  name                = "${var.custom_policies_prefix}_{{policyPartialName}}"
  policy_type         = "Custom"
  mode                = "indexed"
  display_name        = "${var.custom_policies_prefix}_{{policyPartialName}}"
  description         = "${var.custom_policies_prefix}_{{policyPartialName}} ${var.deployment_version}"
  management_group_id = "${var.management_group_id}"
  metadata            = <<METADATA
{ 
    "category": "Monitoring" 
}
METADATA
  policy_rule = <<POLICY_RULE
{
    "if": {
        "field": "type",
        "equals": "{{resourceType}}"
    },
    "then": {
        "effect": "deployIfNotExists",
        "details": {
            "type": "Microsoft.Insights/diagnosticSettings",
            "name": "setByPolicy",
            "roleDefinitionIds": [
                "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
                "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
            ],
            "deployment": {
                "properties": {
                    "mode": "incremental",
                    "template": {
                        "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                        "contentVersion": "1.0.0.0",
                        "parameters": {
                            "diagSettingsName": {
                                "type": "string"
                            },
                            "resourceName": {
                                "type": "string"
                            },
                            "logAnalytics": {
                                "type": "string"
                            },
                            "location": {
                                "type": "string"
                            }
                        },
                        "variables": {},
                        "resources": [{
                            "type": "{{resourceType}}/providers/diagnosticSettings",
                            "apiVersion": "2017-05-01-preview",
                            "name": "[concat(parameters('resourceName'), '/', 'Microsoft.Insights/', parameters('diagSettingsName'))]",
                            "location": "[parameters('location')]",
                            "dependsOn": [],
                            "properties": {
                                "workspaceId": "[parameters('logAnalytics')]",
                                {% if hasMetric %}
                                "metrics": [
                                                {
                                                    "category": "AllMetrics",
                                                    "enabled": true,
                                                    "retentionPolicy": {
                                                        "enabled": false,
                                                        "days": 0
                                                    }
                                                }
                                            ],
                                {% endif %}
                                "logs": [
                                  {% for cat in logCategories %}
                                  {
                                    "category": "{{cat}}",
                                    "enabled": "true"
                                  } {{ "," if not loop.last }}
                                  {% endfor %}
                                ]
                                
                            }
                        }],
                        "outputs": {}
                    },
                    "parameters": {
                        "diagSettingsName": {
                            "value": "[parameters('diagSettingsName')]"
                        },
                        "logAnalytics": {
                            "value": "[parameters('logAnalytics')]"
                        },
                        "location": {
                            "value": "[field('location')]"
                        },
                        "resourceName": {
                            "value": "[field('name')]"
                        }
                    }
                }
            }
        }
    }
}
POLICY_RULE

  parameters = <<PARAMETERS
{
   "diagSettingsName": {
        "metadata": {
            "description": "Diagnostic Settings Name. Must be unique per resource.",
            "displayName": "Diagnostic Settings Name"
        },
        "type": "String"
    },
    "logAnalytics": {
        "metadata": {
            "description": "Select the Log Analytics workspace from dropdown list",
            "displayName": "Log Analytics Workspace",
            "strongType": "omsWorkspace"
        },
        "type": "String"
    }
}
PARAMETERS
}
