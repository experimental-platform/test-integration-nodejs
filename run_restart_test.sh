#!/usr/bin/env bash
# enable fail detection...
set -e

echo "List of running processes (asserting their existance)"
vagrant ssh -c "docker exec dokku dokku ls" | grep running

echo -e "\n\nRebooting the system now:\n"
vagrant ssh -c "nohup sudo reboot &"
sleep 10

COUNTER=0
MAXCOUNT=120
SLEEPTIME=2

while true ; do
    COUNTER=$((COUNTER + 1))
    sleep ${SLEEPTIME}
    HOSTIP=$(vagrant ssh-config | awk '/HostName/ {print $2}')
    echo -e "$(date)\t(${COUNTER}) Waiting for connection to ${HOSTIP}"
    nc -z $HOSTIP 8022 2>/dev/null | true
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
        echo -e "\n\n$(date)\tDROPLET STATUS IS OKAY\n\n"
        break
    fi
    if [[ ${COUNTER} -gt ${MAXCOUNT} ]]; then
        echo -e "\n\n\n\n$(date)\tERROR CONNECTION TIMEOUT... trying anyhow...\n\n\n\n"
        break
    fi
done

echo -e "\n\n\nList of running processes (after reboot)\n"
vagrant ssh -c "docker exec dokku dokku ls"

# the actual test for running containers
vagrant ssh -c "docker exec dokku dokku ls" | grep running