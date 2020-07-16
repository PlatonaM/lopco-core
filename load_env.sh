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


hub_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

conf_file="hub.conf"

conf_vars=(
    "CC_HUB_ENVIRONMENT=prod"
    "CC_DOCKER_HUB_API=https://registry-1.docker.io/v2"
    "CC_DOCKER_HUB_AUTH=https://auth.docker.io/token"
    "CC_HUB_UPDATER_DELAY=600"
    "CC_HUB_UPDATER_LOG_LVL=1"
)

env_vars=(
    "CC_HUB_HOST_IP=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)"
    "CC_HUB_PATH=$hub_dir"
)


installHubEnvLoader() {
    g_bashrc="/etc/bash.bashrc"
    line="source /opt/client-connector-hub/load_env.sh"
    if ! grep -qxF "$line" $g_bashrc; then
        echo "updating $g_bashrc ..."
        echo "
# Provide environment variables for client-connector-hub
$line
" >> $g_bashrc
    fi
}


initHubConf() {
    echo "creating $conf_file ..."
    truncate -s 0 $hub_dir/$conf_file
    for var in "${conf_vars[@]}"; do
        echo "$var" >> $hub_dir/$conf_file
    done
}


updateHubConf() {
    echo "updating $conf_file ..."
    truncate -s 0 $hub_dir/$conf_file
    for var in "${conf_vars[@]}"; do
        var_name=$(echo "$var" | cut -d'=' -f1)
        if [[ -z "${!var_name}" ]]; then
            echo "$var" >> $hub_dir/$conf_file
        else
            echo "$var_name=${!var_name}" >> $hub_dir/$conf_file
        fi
    done
}


loadHubConf() {
    while IFS= read -r line; do
        export "$line"
    done < $hub_dir/$conf_file
}


loadHubEnv() {
  for var in "${env_vars[@]}"; do
      export "$var"
  done
}


if [[ -z "$1" ]]; then
    loadHubConf
    loadHubEnv
else
    case "$1" in
        install)
            initHubConf
            installHubEnvLoader
            exit 0
            ;;
        update)
            loadHubConf
            updateHubConf
            exit 0
            ;;
        *)
            echo "unknown argument: '$1'"
            exit 1
    esac
fi
