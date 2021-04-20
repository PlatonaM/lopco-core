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


# Log levels:
# debug   = 0
# info    = 1
# warning = 2
# error   = 3


log_lvl=("debug" "info" "warning" "error")

current_date="$(date +"%m-%d-%Y")"


installUpdaterService() {
    echo "creating systemd service ..."
    echo "[Unit]
After=docker.service

[Service]
ExecStart=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/updater.sh
Restart=always

[Install]
WantedBy=default.target
" > /etc/systemd/system/lopco-updater.service
    if [[ $? -eq 0 ]]; then
        if chmod 664 /etc/systemd/system/lopco-updater.service; then
            echo "successfully created service"
            echo "reloading daemon ..."
            if systemctl daemon-reload; then
                echo "enabling systemd service ..."
                if systemctl enable lopco-updater.service; then
                    echo "successfully enabled service"
                    return 0
                else
                    echo "enabling service failed"
                fi
            else
                echo "reloading daemon failed"
            fi
        else
            echo "setting premissions failed"
        fi
    else
        echo "creating service failed"
    fi
    return 1
}


log() {
    if [ $1 -lt $LOPCO_UPDATER_LOG_LVL ]; then
        return 0
    fi
    logger=""
    if ! [[ -z "${log_lvl[$1]}" ]]; then
        logger=" [${log_lvl[$1]}]"
    fi
    first=1
    while read -r line; do
        if [ "$first" -eq "1" ]; then
            echo "[$(date +"%m.%d.%Y %I:%M:%S %p")]$logger $line" >> $LOPCO_CORE_PATH/logs/updater.log 2>&1
            first=0
        else
            echo "$line" >> $LOPCO_CORE_PATH/logs/updater.log 2>&1
        fi
    done
}


rotateLog() {
    if [ "$current_date" != "$(date +"%m-%d-%Y")" ]; then
        cp logs/updater.log logs/updater-$current_date.log
        truncate -s 0 logs/updater.log
        current_date="$(date +"%m-%d-%Y")"
    fi
}


updateSelf() {
    echo "checking for updates ..." | log 1
    update_result=$(git remote update 3>&1 1>&2 2>&3 >/dev/null)
    if ! [[ $update_result = *"fatal"* ]] || ! [[ $update_result = *"error"* ]]; then
        status_result=$(git status)
        if [[ $status_result = *"behind"* ]]; then
            echo "downloading and applying updates ..." | log 1
            pull_result=$(git pull 3>&1 1>&2 2>&3 >/dev/null)
            if ! [[ $pull_result = *"fatal"* ]] || ! [[ $pull_result = *"error"* ]]; then
                echo "$(./load_env.sh update)" | log 1
                echo "update success" | log 1
                return 0
            else
                echo "$pull_result" | log 3
                return 1
            fi
        else
            echo "up-to-date" | log 1
            return 2
        fi
    else
        echo "checking for updates - failed" | log 3
        return 1
    fi
}


redeployContainer() {
    docker-compose --ansi never up -d "$1" 2>&1 | log 0
    return ${PIPESTATUS[0]}
}


updateCore() {
    for file in .updater_com/*; do
        if [[ -f "$file" ]] && [[ $(wc -l < "$file") -lt 1 ]]; then
            srv=$(cat "$file")
            if redeployContainer $srv; then
                printf "\n0" >> "$file"
                echo "($srv) redeploying container successful" | log 1
                if [[ "$srv" == "update-manager" ]]; then
                    rm "$file"
                fi
            else
                printf "\n1" >> "$file"
                echo "($srv) redeploying container failed" | log 3
            fi
        fi
    done
}


initCheck() {
    if [ ! -d "logs" ]; then
        mkdir logs
    fi
}


strtMsg() {
    echo "***************** starting lopco-core-updater *****************" | log 4
    echo "running in: '$LOPCO_CORE_PATH'" | log 4
    echo "check every: '$LOPCO_UPDATER_DELAY' seconds" | log 4
    echo "check self every: '$LOPCO_SELF_UPDATE_DELAY' seconds" | log 4
    echo "environment: '$LOPCO_CORE_ENVIRONMENT'" | log 4
    echo "log level: '${log_lvl[$LOPCO_UPDATER_LOG_LVL]}'" | log 4
    echo "PID: '$$'" | log 4
}


cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ -z "$1" ]]; then
    source ./load_env.sh
    initCheck
    strtMsg
    if [[ -f .rd_flag ]]; then
        echo "redeploying containers ..." | log 1
        docker-compose --ansi never up -d 2>&1 | log 0
        if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
            echo "redeploying containers successful" | log 1
            rm .rd_flag
        else
            echo "redeploying containers failed" | log 3
            echo "restarting ..." | log 1
            exit 0
        fi
    fi
    last_update=$(date +%s)
    while true; do
        sleep $LOPCO_UPDATER_DELAY
        rotateLog
        now=$(date +%s)
        if [[ $(( now - last_update )) -gt $LOPCO_SELF_UPDATE_DELAY ]]; then
            if updateSelf; then
                if touch .rd_flag; then
                    echo "containers will be redeployed after restart ..." | log 1
                fi
                echo "restarting ..." | log 1
                break
            fi
            last_update=$now
        fi
        updateCore
    done
    exit 0
else
    case "$1" in
        install)
            echo "installing lopco-core-updater ..."
            ./load_env.sh install
            if installUpdaterService; then
                echo "installation successful"
                exit 0
            else
                echo "installation failed"
                exit 1
            fi
            ;;
        deploy)
            initCheck
            source ./load_env.sh ""
            if [[ -z "$2" ]]; then
                echo "deploying lopco-core containers ..."
                echo
                echo "environment: '$LOPCO_CORE_ENVIRONMENT'"
                echo
                if docker-compose up -d; then
                    echo
                    echo "deploying containers successful"
                    exit 0
                else
                    echo
                    echo "deploying containers failed"
                    exit 1
                fi
            else
                echo "deploying $2 container ..."
                echo
                echo "environment: '$LOPCO_CORE_ENVIRONMENT'"
                echo
                if docker-compose up -d "$2"; then
                    echo
                    echo "deploying container successful"
                    exit 0
                else
                    echo
                    echo "deploying container failed"
                    exit 1
                fi
            fi
            ;;
        pull)
            source ./load_env.sh ""
            if [[ -z "$2" ]]; then
                echo "pulling lopco-core images ..."
                echo
                echo "environment: '$LOPCO_CORE_ENVIRONMENT'"
                echo
                if docker-compose pull; then
                    echo
                    echo "pulling images successful"
                    exit 0
                else
                    echo
                    echo "pulling images failed"
                    exit 1
                fi
            else
                echo "pulling $2 image ..."
                echo
                echo "environment: '$LOPCO_CORE_ENVIRONMENT'"
                echo
                if docker-compose pull "$2"; then
                    echo
                    echo "pulling image successful"
                    exit 0
                else
                    echo
                    echo "pulling image failed"
                    exit 1
                fi
            fi
            ;;
        *)
            echo "unknown argument: '$1'"
            exit 1
    esac
fi
