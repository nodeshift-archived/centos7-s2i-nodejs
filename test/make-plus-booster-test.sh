#!/bin/bash

node_version=$(cat ../versions.mk|grep NODE_VERSION|cut -d'=' -f2)
npm_version=$(cat ../versions.mk|grep NPM_VERSION|cut -d'=' -f2)
image_name=rhoar/local-centos-nodejs-s2i
booster_image_name=nodejs-rest-http-s2i-rhoar

make -C ..

# Build the docker image
docker build -t $image_name --build-arg NODE_VERSION=$node_version --build-arg NPM_VERSION=$npm_version ../.

pushd ../../nodejs-rest-http/

s2i build . ${image_name}:latest $booster_image_name --pull-policy never

docker run -p 8080:8080 $booster_image_name
docker run -e DEV_MODE=true -p 8080:8080 $booster_image_name

popd
