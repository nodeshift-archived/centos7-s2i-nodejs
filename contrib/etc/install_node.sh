#!/bin/bash

set -ex
yum install -y --setopt=tsflags=nodocs openssl
yum install -y https://github.com/bucharest-gold/node-rpm/releases/download/v${NODE_VERSION}/rhoar-nodejs-${NODE_VERSION}-1.el7.centos.x86_64.rpm
yum install -y https://github.com/bucharest-gold/node-rpm/releases/download/v${NODE_VERSION}/npm-${NPM_VERSION}-1.${NODE_VERSION}.1.el7.centos.x86_64.rpm

# Install nodemon and yarn
npm install -g nodemon
ln -s /usr/lib/node_modules/nodemon/bin/nodemon.js /usr/bin/nodemon
npm install -g yarn -s &>/dev/null

# Make /opt/app-root owned by user 1001
chown -R 1001:0 /opt/app-root
chmod -R ug+rwx /opt/app-root

# Fix permissions for the npm update-notifier
# chmod -R 777 /opt/app-root/src/.config

# Delete NPM things that we don't really need (like tests) from node_modules
find /usr/local/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf

# Clean up the stuff we downloaded
yum clean all -y
