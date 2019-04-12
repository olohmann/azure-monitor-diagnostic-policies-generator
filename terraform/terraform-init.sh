#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

terraform init
#\
#-get-plugins=false \
#  -verify-plugins=false \
#  -input=false
