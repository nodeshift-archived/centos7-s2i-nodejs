# OpenShift Builder Images for Node.js Applications

[![Build Status](https://travis-ci.org/bucharest-gold/centos7-s2i-nodejs.svg?branch=master)](https://travis-ci.org/bucharest-gold/centos7-s2i-nodejs)
[![](https://images.microbadger.com/badges/image/bucharestgold/centos7-s2i-nodejs.svg)](https://microbadger.com/images/bucharestgold/centos7-s2i-nodejs "Get your own image badge on microbadger.com")

This repository contains sources for an [s2i](https://github.com/openshift/source-to-image) builder image, based on CentOS7 and Node.js releases from nodejs.org.

[![docker hub stats](http://dockeri.co/image/bucharestgold/centos7-s2i-nodejs)](https://hub.docker.com/r/bucharestgold/centos7-s2i-nodejs/)

For more information about using these images with OpenShift, please see the
official [OpenShift Documentation](https://docs.openshift.org/latest/using_images/s2i_images/nodejs.html).

## Versions

Node.js versions [currently provided](https://hub.docker.com/r/bucharestgold/centos7-s2i-nodejs/tags/):

<!-- versions.start -->
* **`8.4.0`**: (8.x, latest)
* **`7.10.1`**: (7.x)
* **`6.11.2`**: (6.x, Boron)
* **`5.12.0`**: (5.x)
* **`4.8.4`**: (4.x, Argon)
<!-- versions.end -->

## Usage

Using this image with OpenShift `oc` command line tool, or with `s2i` directly, will
assemble your application source with any required dependencies to create a new image.
This resulting image contains your Node.js application and all required dependencies,
and can be run either by OpenShift Origin or by Docker.

The [`oc` command-line tool](https://github.com/openshift/origin/releases) can be used to start a build, layering your desired nodejs `REPO_URL` sources into a centos7 image with your selected `RELEASE` of Node.js via the following command format:

```
oc new-app bucharestgold/centos7-s2i-nodejs:RELEASE~REPO_URL
```

For example, you can run a build (including `npm install` steps), using  [`s2i-nodejs`](http://github.com/bucharest-gold/s2i-nodejs) example repo, and the `latest` release of
Node.js with:

```
oc new-app bucharestgold/centos7-s2i-nodejs:latest~https://github.com/bucharest-gold/s2i-nodejs
```

<!--
Or, to run the latest `lts-6` release:

```
oc new-app bucharestgold/centos7-s2i-nodejs:lts-6~https://github.com/bucharest-gold/s2i-nodejs
```

You can try using any of the available tagged Node.js releases, and your own repo sources - as long as your application source will init correctly with `npm start`, and listen on port 8080.
-->

### Environment variables

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

### Using Docker's exec

To change your source code in a running container, use Docker's [exec](http://docker.io) command:

```
docker exec -it <CONTAINER_ID> /bin/bash
```

After you [Docker exec](http://docker.io) into the running container, your current directory is set to `/opt/app-root/src`, where the source code for your application is located.

### Using OpenShift's rsync

If you have deployed the container to OpenShift, you can use [oc rsync](https://docs.openshift.org/latest/dev_guide/copy_files_to_container.html) to copy local files to a remote container running in an OpenShift pod.

## Builds

The [Source2Image cli tools](https://github.com/openshift/source-to-image/releases) are available as a standalone project, allowing you to [run builds outside of OpenShift](https://github.com/bucharest-gold/origin-s2i-nodejs/blob/master/nodejs.org/README.md#usage).

This example will produce a new docker image named `webapp`:

```
s2i build https://github.com/bucharest-gold/s2i-nodejs bucharestgold/centos7-s2i-nodejs:current webapp
```

## Installation

There are several ways to make this base image and the full list of tagged Node.js releases available to users during OpenShift's web-based "Add to Project" workflow.

### For OpenShift Online Next Gen Developer Preview
Those without admin privileges can install the latest Node.js releases within their project context with:

```
oc create -f https://raw.githubusercontent.com/bucharest-gold/origin-s2i-nodejs/master/image-streams.json
```

To ensure that each of the latest Node.js release tags are available and displayed correctly in the web UI, try upgrading / reinstalling the image stream:

```
oc delete is/centos7-s2i-nodejs ; oc create -f https://raw.githubusercontent.com/bucharest-gold/origin-s2i-nodejs/master/image-streams.json
```

If you've (automatically) imported this image using the [`oc new-app` example command](#usage), then you may need to clear the auto-imported image stream reference and re-install it.

### For Administrators

Administrators can make these Node.js releases available globally (visible in all projects, by all users) by adding them to the `openshift` namespace:

```
oc create -n openshift -f https://raw.githubusercontent.com/bucharest-gold/origin-s2i-nodejs/master/image-streams.json
```

To replace [the default SCL-packaged `openshift/nodejs` image](https://hub.docker.com/r/openshift/nodejs-010-centos7/) (admin access required), run:

```
oc delete is/nodejs -n openshift ; oc create -n openshift -f https://raw.githubusercontent.com/bucharest-gold/origin-s2i-nodejs/master/centos7-s2i-nodejs.json
```

## Building your own Builder images

Clone a copy of this repo to fetch the build sources:

```
git clone https://github.com/bucharest-gold/origin-s2i-nodejs.git
cd origin-s2i-nodejs
```

### Requirements - docker-squash

`pip install docker-squash`

To build your own S2I Node.js builder images from scratch, run:

```
make all
```