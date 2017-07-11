#!/bin/bash

set -ex

# Download and install a binary from nodejs.org
# Add the gpg keys listed at https://github.com/nodejs/node
for key in \
   94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
   FD3A5288F042B6850C66B31F09FE44734EB7990E \
   71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
   DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
   C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
   B9AE9905FFD7803F25714661B63B535A4C206CA9 \
   56730D5401028683275BD23C23EFEFE93C4CFFFE \
; do
  gpg -q --keyserver pool.sks-keyservers.net --recv-keys "$key";
  echo "$key:6" | gpg --import-ownertrust
done

# Get the node binary and it's shasum
curl -O -sSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz
curl -O -sSL https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt.asc
gpg --verify SHASUMS256.txt.asc

# Validate the release
grep " node-v${NODE_VERSION}-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c -

# Unpack and install node/npm
tar -zxf node-v${NODE_VERSION}-linux-x64.tar.gz -C /usr/local --strip-components=1
npm install -g npm@${NPM_VERSION} -s &>/dev/null

# Install yarn
npm install -g yarn -s &>/dev/null

# Fix permissions for the npm update-notifier
chmod -R 777 /opt/app-root/src/.config

# Delete NPM things that we don't really need (like tests) from node_modules
find /usr/local/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf

# Clean up the stuff we downloaded
rm -rf ~/node-v${NODE_VERSION}-linux-x64.tar.gz ~/SHASUMS256.txt.asc /tmp/node-v${NODE_VERSION} ~/.npm ~/.node-gyp ~/.gnupg /usr/share/man /tmp/* /usr/local/lib/node_modules/npm/man /usr/local/lib/node_modules/npm/doc /usr/local/lib/node_modules/npm/html
