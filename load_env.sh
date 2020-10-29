#!/bin/bash

#   Copyright 2019 InfAI (CC SES)
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


core_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

conf_file="core.conf"

conf_vars=(
    "LOPCO_CORE_ENVIRONMENT=latest"
    "LOPCO_LOG_LEVEL=info"
    "LOPCO_SUBNET=10.10.0.0/16"
    "LOPCO_UPDATER_DELAY=5"
    "LOPCO_UPDATER_LOG_LVL=1"
    "LOPCO_SELF_UPDATE_DELAY=18000"
    "LOPCO_UM_UPDATE_SECOND=30"
    "LOPCO_UM_UPDATE_MINUTE=30"
    "LOPCO_UM_UPDATE_HOUR=1"
    "LOPCO_UM_UPDATE_INTERVAL=10800"
    "LOPCO_UM_CORE_DELAY=5"
    "LOPCO_UM_CORE_TIMEOUT=90"
    "LOPCO_JM_JOBS_CHECK=5"
    "LOPCO_JM_JOBS_MAX_NUM=10"
    "LOPCO_DM_DOCKER_DISABLE_RM=False"
)

env_vars=(
    "LOPCO_CORE_PATH=$core_dir"
    "LOPCO_CORE_DIR_NAME=${PWD##*/}"
)


initConf() {
    echo "creating $conf_file ..."
    truncate -s 0 $core_dir/$conf_file
    for var in "${conf_vars[@]}"; do
        echo "$var" >> $core_dir/$conf_file
    done
}


updateConf() {
    echo "updating $conf_file ..."
    truncate -s 0 $core_dir/$conf_file
    for var in "${conf_vars[@]}"; do
        var_name=$(echo "$var" | cut -d'=' -f1)
        if [[ -z "${!var_name}" ]]; then
            echo "$var" >> $core_dir/$conf_file
        else
            echo "$var_name=${!var_name}" >> $core_dir/$conf_file
        fi
    done
}


loadConf() {
    while IFS= read -r line; do
        export "$line"
    done < $core_dir/$conf_file
}


loadEnv() {
  for var in "${env_vars[@]}"; do
      export "$var"
  done
}


if [[ -z "$1" ]]; then
    loadConf
    loadEnv
else
    case "$1" in
        install)
            initConf
            exit 0
            ;;
        update)
            loadConf
            updateConf
            exit 0
            ;;
        *)
            echo "unknown argument: '$1'"
            exit 1
    esac
fi
