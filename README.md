# OpenShift Builder Images for Node.js Applications

[![Build Status](https://travis-ci.org/bucharest-gold/centos7-s2i-nodejs.svg?branch=master)](https://travis-ci.org/bucharest-gold/centos7-s2i-nodejs)
[![](https://images.microbadger.com/badges/image/bucharestgold/centos7-s2i-nodejs.svg)](https://microbadger.com/images/bucharestgold/centos7-s2i-nodejs "Get your own image badge on microbadger.com")

This repository contains sources for an [s2i](https://github.com/openshift/source-to-image) builder image, based on CentOS7 and Node.js RPM releases from https://github.com/bucharest-gold/node-rpm. The RPMs and this builder image are the upstream
sources for the [Red Hat OpenShift Application Runtimes](https://developers.redhat.com/products/rhoar/overview/) Node.js
distribution.

[![docker hub stats](http://dockeri.co/image/bucharestgold/centos7-s2i-nodejs)](https://hub.docker.com/r/bucharestgold/centos7-s2i-nodejs/)

## Versions

Node.js versions [currently provided](https://hub.docker.com/r/bucharestgold/centos7-s2i-nodejs/tags).

Version  | Tag
-------- | -----
`10.1.0` | (10.x)
`9.11.1` | (9.x, latest)
`8.11.2` | (8.x, Carbon)
`7.10.1` | (7.x)
`6.11.4` | (6.x, Boron)
`5.12.0` | (5.x)
`4.8.4`  | (4.x, Argon)

## Usage

Using this image with OpenShift `oc` command line tool, or with `s2i` directly, will
assemble your application source with its required dependencies, creating a new
container image. This image contains your Node.js application and all required dependencies,
and can be run either on OpenShift or directly on Docker.

### OpenShift

The [`oc` command-line tool](https://github.com/openshift/origin/releases) can be
used to start a build, layering your desired nodejs `REPO_URL` sources into a centos7
image with your selected `RELEASE` of Node.js via the following command format:

```
oc new-app bucharestgold/centos7-s2i-nodejs:latest~https://github.com/bucharest-gold/nodejs-rest-http
```

#### OpenShift Catalog

With OpenShift, it is also possible to import this builder image into the
online Catalog, so that applications can be created and deployed using this Node.js
image through the web-based user interface. To import the images, run the following
openshift command.

```
oc create -f imagestreams/image-stream.yml
```

### Docker

The [Source2Image cli tools](https://github.com/openshift/source-to-image/releases)
are available as a standalone project, allowing you to run your application directly
in Docker.

This example will produce a new Docker image named `webapp`:

```
s2i build https://github.com/bucharest-gold/nodejs-rest-http bucharestgold/centos7-s2i-nodejs:latest webapp
```

Then you can run the application image like this.

```
docker run -p 8080:8080 --rm -it webapp
```

## Configuration

Use the following environment variables to configure the runtime behavior of the
application image created from this builder image.

NAME        | Description
------------|-------------
NPM_RUN     | Select an alternate / custom runtime mode, defined in your `package.json` file's [`scripts`](https://docs.npmjs.com/misc/scripts) section (default: npm run "start")
NPM_MIRROR  | Sets the npm registry URL
NODE_ENV    | Node.js runtime mode (default: "production")
HTTP_PROXY  | use an npm proxy during assembly
HTTPS_PROXY | use an npm proxy during assembly

One way to define a set of environment variables is to include them as key value pairs
in a `.s2i/environment` file in your source repository.

Example: `DATABASE_USER=sampleUser`

### Debug Mode

When `NODE_ENV` is set to `development` or `DEV_MODE` is set to true, your Node.js application
will be started using `nodemon`.

```
npx nodemon --inspect="$DEBUG_PORT"
```

### Using Docker's exec

To change your source code in a running container, use Docker's [exec](http://docker.io) command:

```
docker exec -it <CONTAINER_ID> /bin/bash
```

After you [Docker exec](http://docker.io) into the running container, your current directory is set
to `/opt/app-root/src`, where the source code for your application is located.

### Using OpenShift's rsync

If you have deployed your application to OpenShift, you can use
[oc rsync](https://docs.openshift.org/latest/dev_guide/copy_files_to_container.html) to copy local
files to a remote container running in an OpenShift pod.
