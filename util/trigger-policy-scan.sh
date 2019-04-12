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
__VERBOSE=${__VERBOSE:=4}

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

BEARER_TOKEN=$(az account get-access-token --output json --query 'accessToken' | tr -d '"' | tr -d '\n')
HTTP_OUTPUT=$(curl -vvv -d "" -H "Authorization: Bearer ${BEARER_TOKEN}" -X POST "https://management.azure.com/subscriptions/${SUBSCRIPTION}/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2018-07-01-preview" 2>&1)

SLEEP_INTERVAL=10
SLEEP_COUNTER=0

if echo "$HTTP_OUTPUT" | grep -q -E '< HTTP/[0-9.]+ 202 Accepted'; then
    STATUS_URL=$(echo -n "$HTTP_OUTPUT" | grep -E 'Location: ([^ \n].*)' | sed -E 's/< Location: //g' | tr -d '\r' | tr -d '\n')
    echo "Polling Azure Policy Compliance Status..." 
    HTTP_POLL_OUTPUT=$(curl -vvv -H "Authorization: Bearer ${BEARER_TOKEN}" -X GET "${STATUS_URL}" 2>&1)

    while echo "$HTTP_POLL_OUTPUT" | grep -q -E '< HTTP/[0-9.]+ 202 Accepted'; do
        sleep $SLEEP_INTERVAL
        HTTP_POLL_OUTPUT=$(curl -vvv -H "Authorization: Bearer ${BEARER_TOKEN}" -X GET "${STATUS_URL}" 2>&1)
        SLEEP_COUNTER=$((SLEEP_COUNTER + 1))
        echo "$(date +%Y-%m-%d_%H-%M-%S) Azure Policy Compliance is still being evaluated... ($(expr ${SLEEP_INTERVAL} \* ${SLEEP_COUNTER})s elapsed)"
    done

    if echo "$HTTP_POLL_OUTPUT" | grep -q -E '{"status":"Succeeded"}'; then
        echo "Azure Policy Compliance evaluation has completed."
    else 
        echo "Unknown error in Azure Policy Compliance evaluation."
        echo $HTTP_POLL_OUTPUT
    fi
else
    echo "Unknown error in Azure Policy Compliance evaluation."
    echo $HTTP_OUTPUT
fi
