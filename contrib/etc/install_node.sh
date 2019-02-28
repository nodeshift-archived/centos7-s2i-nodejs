#!/bin/bash

set -ex
INSTALL_PKGS="centos-release-scl-rh nss_wrapper rh-git29"

yum remove -y rh-nodejs8 rh-nodejs8-npm rh-nodejs8-nodejs-nodemon

yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS
ln -fs /opt/rh/rh-git29/root/usr/bin/git /usr/bin/git

# Ensure git uses https instead of ssh for NPM install
# See: https://github.com/npm/npm/issues/5257
echo -e "Setting git config rules"
git config --system url."https://github.com".insteadOf git@github.com:
git config --global url."https://github.com".insteadOf ssh://git@github.com
git config --system url."https://".insteadOf git://
git config --system url."https://".insteadOf ssh://
git config --list

yum install -y https://github.com/nodeshift/node-rpm/releases/download/v${NODE_VERSION}/rhoar-nodejs-${NODE_VERSION}-1.el7.centos.x86_64.rpm
yum install -y https://github.com/nodeshift/node-rpm/releases/download/v${NODE_VERSION}/npm-${NPM_VERSION}-1.${NODE_VERSION}.1.el7.centos.x86_64.rpm

rpm -V $INSTALL_PKGS
yum clean all -y
ldconfig

# Install yarn
npm install -g yarn -s &>/dev/null

# Make sure npx is available
if [ ! -h /usr/bin/npx ] ; then
  ln -s /usr/lib/node_modules/npm/bin/npx-cli.js /usr/bin/npx
fi

echo "---> Setting directory write permissions"
fix-permissions /opt/app-root

# Delete NPM things that we don't really need (like tests) from node_modules
find /usr/local/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf

# Clean up the stuff we downloaded
yum clean all -y
