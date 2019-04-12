#!/usr/bin/env python
import sys
import json
import copy
from pprint import pprint
from jinja2 import Environment, FileSystemLoader

MIN_VERSION_PY = (3, 2)
if (MIN_VERSION_PY[0] >= sys.version_info[0] and MIN_VERSION_PY[1] >= sys.version_info[1]):
      sys.exit(
        "ERROR: Python requires python %s. ;"
        " You are running %s." % (
          '.'.join(map(str, MIN_VERSION_PY)), 
          '.'.join(map(str, sys.version_info))
        )
      )

def get_policy_name_suffix(resourceType):
    return resourceType.split('/')[0].replace('.', '_')

def get_policy_partial_name(namePrefix, resourceType):
    return namePrefix + '_' + get_policy_name_suffix(resourceType)

def config_item_to_terraform_variable_policy_id(item): 
    return "${azurerm_policy_definition.policy_" + get_policy_partial_name(item["namePrefix"], item["resourceType"]) + ".id}"

with open('az-monitor-custom-policies-generator-config.json') as f:
    config = json.load(f)

file_loader = FileSystemLoader('templates')
env = Environment(loader=file_loader)

# Load Policy Templates (generic + specific)
custom_policy_default_template = env.get_template('az-monitor-custom-policies-template.tf')
custom_policy_sql_server_template = env.get_template('az-monitor-custom-policies-template-sql-server.tf')

# Generate individual Policies per Resource
for item in config:
    item['policyPartialName'] = get_policy_partial_name(item['namePrefix'], item['resourceType'])
    output_file_path='../terraform/az-monitor-custom-policies-generated/' + item['policyPartialName'] + '.tf'
    
    output = ''
    if item['resourceType'] == 'Microsoft.Sql/servers/databases': 
        output = custom_policy_sql_server_template.render(item)
    else:
        output = custom_policy_default_template.render(item)

    print(output,file=open(output_file_path, 'w'))

# Generate a single Policy Initiative
initiative_template = env.get_template('az-monitor-custom-policies-initiative-template.tf')
policyDefinitionIds = map(config_item_to_terraform_variable_policy_id, config)
print(initiative_template.render(policyDefinitionIds=policyDefinitionIds), file=open('../terraform/az-monitor-custom-policies-generated/DIAG_0000_Initiative.tf', 'w'))
