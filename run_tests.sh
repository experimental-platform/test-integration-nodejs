#!/usr/bin/env bash
# enable fail detection...
set -e
source /initialize.sh

initialize

echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
HOSTIP=$(vagrant ssh-config | awk '/HostName/ {print $2}')

echo -e "\nSETTING up Dokku SSH key.\n"
cat /.ssh/id_rsa.pub | vagrant ssh -c "docker exec -i dokku sshcommand acl-add dokku root"

echo -e "\nCLONING repo\n"
git clone https://github.com/experimental-platform/nodejs-hello-world.git
cd nodejs-hello-world/
git config user.email "platform@protonet.info"
git config user.name "Protonet Integration Test node.js"
# http://progrium.viewdocs.io/dokku/checks-examples.md
echo -e "WAIT=10\nATTEMPTS=20\n/ Hello" > CHECKS
git add .
git commit -a -m "Initial Commit"
echo -e "\nRUNNING git push to ${HOSTIP}\n"
git remote add dokku ssh://dokku@${HOSTIP}:8022/node-js-app
# destroy in case it's already deployed
ssh -t -p 8022 dokku@${HOSTIP} apps:destroy node-js-app force || true
# ssh -t -p 8022 dokku@${HOSTIP} trace on
git push dokku master

wget -O - http://${HOSTIP}/node-js-app
