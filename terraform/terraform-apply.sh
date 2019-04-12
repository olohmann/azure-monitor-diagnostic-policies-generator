#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

terraform apply \
 tfplan
