FROM centos/s2i-base-centos7
# This image provides a Node.JS environment you can use to run your
# Node.JS applications.

EXPOSE 8080

# This image will be initialized with "npm run $NPM_RUN"
# See https://docs.npmjs.com/misc/scripts, and your repo's package.json
# file for possible values of NPM_RUN
ARG NODE_VERSION
ARG NPM_VERSION

ENV NPM_RUN=start \
    NODE_VERSION=${NODE_VERSION} \
    NPM_VERSION=${NPM_VERSION} \
    NODE_LTS=false \
    NPM_CONFIG_LOGLEVEL=info \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    NPM_CONFIG_TARBALL=/usr/share/node/node-v${NODE_VERSION}-headers.tar.gz \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
    DEBUG_PORT=5858 \
    SUMMARY="Platform for building and running Node.js ${NODE_VERSION} applications" \
    DESCRIPTION="Node.js $NODEJS_VERSION available as docker container is a base platform for \
building and running various Node.js $NODEJS_VERSION applications and frameworks. \
Node.js is a platform built on Chrome's JavaScript runtime for easily building \
fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model \
that makes it lightweight and efficient, perfect for data-intensive real-time applications \
that run across distributed devices." \
    LD_LIBRARY_PATH=/opt/rh/httpd24/root/usr/lib64

LABEL io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Node.js $NODE_VERSION" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,nodejs,nodejs-$NODE_VERSION" \
      com.redhat.deployments-dir="/opt/app-root/src" \
      com.redhat.dev-mode="DEV_MODE:false" \
      com.redhat.dev-mode.port="DEBUG_PORT:5858" \
      maintainer="Lance Ball <lball@redhat.com>" \
      summary="$SUMMARY" \
      description="$DESCRIPTION" \
      version="$NODE_VERSION" \
      name="nodeshift/centos7-s2i-nodejs" \
      usage="s2i build . nodeshift/centos7-s2i-nodejs myapp"

COPY ./s2i/ $STI_SCRIPTS_PATH
COPY ./contrib/ /opt/app-root

RUN /opt/app-root/etc/install_node.sh

USER 1001

# Set the default CMD to print the usage
CMD ${STI_SCRIPTS_PATH}/usage
