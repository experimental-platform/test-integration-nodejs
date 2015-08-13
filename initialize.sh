#!/usr/bin/env bash
set -e

function initialize() {
    # maximum number of tries to detect a running dokku
    local MAXCOUNT=450
    # wait time between tries to detect a running dokku
    local SLEEPTIME=2

    CHANNEL=${CHANNEL:=development}

    local i=0
    while true; do
        echo -e "\n\n$(date)\tSTARTING DROPLET\n\n"
        local VAGRANT_RESULT=$(vagrant up)
        echo -e "\n\nINSTALLING PLATFORM CHANNEL ${CHANNEL}."
        vagrant ssh -c "curl https://git.protorz.net/AAL/platform-configure-script/raw/master/platform-configure.sh | sudo CHANNEL=${CHANNEL} sh" > /dev/stderr | true
        if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
            break
        fi
        if [[ ${i} -gt 10 ]]; then
            echo -e "\n\n\nERROR: Couldn't install test platform.\n"
            exit 42
        fi
        i=$[$i+1]
        echo -e "\n\nERROR DURING THE INSTALLATION OF PLATFORM CHANNEL ${CHANNEL}."
        echo -ne "Sleeping 15 seconds..."
        sleep 15
        echo -e " trying again."
        vagrant destroy -f
        sleep 30
    done

    echo -e "INSTALLATION SUCCESSFUL.\n\n"

    local HOSTIP=$(vagrant ssh-config | awk '/HostName/ {print $2}')
    if [[ -z "$HOSTIP" ]]; then
        echo -e "\n\nHOSTIP not set!\n\n"
        exit 42
    fi

    echo -en "\n\n$(date)\tWaiting for connection to ${HOSTIP}"
    local COUNTER=0
    while true ; do
        COUNTER=$((COUNTER + 1))
        sleep ${SLEEPTIME}
        nc $HOSTIP 42423 2>/dev/null | grep "OKAY" >/dev/null 2>&1 | true
        if [[ ${PIPESTATUS[1]} -eq 0 ]]; then
            echo -e "\n\n$(date)\tDROPLET STATUS IS OKAY\n\n"
            break
        fi
        if [[ ${COUNTER} -gt ${MAXCOUNT} ]]; then
            echo -e "\n\n$(date)\tERROR CONNECTION TIMEOUT...\n\n"
            exit 23
        fi
        echo -n '.'
    done
}

