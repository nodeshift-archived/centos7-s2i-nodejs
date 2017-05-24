FROM openshift/base-centos7

# This image provides a Node.JS environment you can use to run your Node.JS
# applications.

EXPOSE 8080

# This image will be initialized with "npm run $NPM_RUN"
# See https://docs.npmjs.com/misc/scripts, and your repo's package.json
# file for possible values of NPM_RUN
ENV NPM_RUN=start \
    NODE_VERSION=7.10.0 \
    NPM_VERSION=4.2.0 \
    V8_VERSION=5.5.372.43 \
    NODE_LTS=false \
    NPM_CONFIG_LOGLEVEL=info \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
    DEBUG_PORT=5858 \
    NODE_ENV=production \
    DEV_MODE=false

LABEL io.k8s.description="Platform for building and running Node.js applications" \
      io.k8s.display-name="Node.js $NODE_VERSION" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,nodejs,nodejs-$NODE_VERSION" \
      com.redhat.deployments-dir="/opt/app-root/src" \
      maintainer="Lance Ball <lball@redhat.com>"

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/ $STI_SCRIPTS_PATH

RUN set -ex ; \
  if [ ! -e /opt/app-root ] ; then mkdir /opt/app-root; fi ; \
  chown -R 1001:0 /opt/app-root && chmod -R ug+rwx /opt/app-root

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

RUN set -ex; \
  /opt/app-root/etc/install_node.sh ; \
  /opt/app-root/etc/set_passwd_permissions.sh 
  
USER 1001

# When the container starts, we always want to make sure the permissions
# are correct in places we care about
# ENTRYPOINT ["/opt/app-root/etc/configure_passwd.sh"]

# Set the default CMD to print the usage of the language image
CMD ${STI_SCRIPTS_PATH}/usage
