variable "custom_policies_prefix" {
  type = "string"
  description = "Prefix for policy definition, e.g. company name."
}

variable "deployment_version" {
  type = "string"
  description = "A version string like v0.1.0. Is placed in descriptions for reference."
}

variable "log_analytics_workspace_id" {
  type = "string" 
  description = "The Log Analytics Workspace were all diagnostic logs information should be stored."
}

variable "diagnostics_settings_name" {
  type = "string"
  description = "The name of the diagnostics config name."
}

variable "scope" {
  type = "string"
  description = "The scope for the policy definition and assignment. E.g. a management group ID or a subscription ID."
}

variable "location" {
  type = "string"
  description = "Location for the Managed Identity created in the policy initiative assignment."
}

variable "management_group_id" {
  type = "string"
  description = "If set, this has to correspond to scope and has to be defined only, if scope is a management group."
  default = ""
}
