#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Log Helper
declare -A LOG_LEVELS
LOG_LEVELS=([0]="emerg" [1]="alert" [2]="crit" [3]="err" [4]="warning" [5]="notice" [6]="info" [7]="debug")
function .log () {
  local LEVEL=${1}
  shift
  if [ ${__VERBOSE} -ge ${LEVEL} ]; then
	if [ ${LEVEL} -ge 3 ]; then
		echo "[${LOG_LEVELS[$LEVEL]}]" "$@" 1>&2
    else 
		echo "[${LOG_LEVELS[$LEVEL]}]" "$@"
	fi
  fi
}

# Defaults
__VERBOSE=${__VERBOSE:=5}

# Check Dependencies
if ! [ -x "$(command -v az)" ]; then
  .log 3 "az is required and was not found in PATH." 
  exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
  .log 3 "curl is required and was not found in PATH." 
  exit 1
fi

# Options
param_errs=0
SUBSCRIPTION=""

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--subscription)
    SUBSCRIPTION="$2"
    shift # past argument
    shift # past value
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Check Options
if [ -z "$SUBSCRIPTION" ]; then .log 3 "Required parameter not defined: --subscription/-s"; param_errs=$((param_errs + 1)); fi
if [ ${param_errs} -gt 0 ]; then 
    .log 3 "Options invalid. Aborting..."
    exit 1
fi 
# -----------------------------------------------------------------------------

for i in `az policy set-definition list -o tsv --query "[?policyType=='Custom'][].name" --subscription ${SUBSCRIPTION}`; do
    az policy set-definition delete -n $i --subscription ${SUBSCRIPTION}
    .log 5 "Deleted policy set definition $i"
done
