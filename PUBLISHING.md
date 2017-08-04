# Publishing the `centos7-s2i-nodejs` images to Docker Hub

When there is a new release of Node.js, these images need to be updated.
Follow these steps to publish. In all cases, you should have `DOCKER_USER`
and `DOCKER_PASS` defined in your environment.

```sh
$ export DOCKER_USER=lanceball
$ export DOCKER_PASS=xxxxxxxxx
```

## Updating node versions

You will need command line tools to update `releases.json`, which contains metadata about each
of the available release versions; and `image-streams.centos7.json`, which provides metadata
for OpenShift integration of these builder images in the OpenShift user interface.

First install the node tools.

```
$ npm install -g node-metadata
$ npm install -g node-image-stream
```

And a nice json formatter called [`jq`](https://stedolan.github.io/jq/download/).

Then use these tools to update the relevant files. Follow the commands outlined below.

```
node-metadata -i 4 5 6 7 8 | jq '.' > releases.json # Write release metadata to disk
node-image-stream -f releases.json -i bucharestgold/centos7-s2i-nodejs > image-streams.centos7.json # write image stream data
git add releases.json image-streams.centos7.json
git commit -a -m "(chore): update node versions"
```

Note that these files are kept up to date in the `master` branch, but any changes
made here should be cherry-picked into the branch being updated.

## New minor or patch-level release

Let's say that Node.js version 7.10.1 is released and we are currently
publishing 7.10.0. This is a patch level version bump. Note that these
steps will be the same for a minor release, for example, in
this case, if Node.js 7.11.0 is released.

Take the following steps to publish the latest version.

```sh
# switch to the branch being published
git checkout 7.x

# update with any changes not present locally
git pull origin 7.x

# Change the version numbers in the readme and Makefile.
# The Makefile has version numbers for Node, NPM and V8.
# You'll need to update all of those. In this case, the
# change should look like this:
# NODE_VERSION=7.10.0
# NPM_VERSION=4.2.0
# V8_VERSION=5.5.372.43
# To obtain the version numbers for NPM and V8, you can
# check out Node's releases metadata:
# https://nodejs.org/dist/index.json
vi README.md Makefile

# Make sure nothing broke
make all

# Then make the docker image tags and publish
make tag publish

# If everything looks good, commit, tag and push to github
git commit -a -m "(chore) update to Node.js 7.10.1"
git tag -s node-7.10.1 "Node.js 7.10.1 release"
git push origin 7.x --follow-tags
```

## New major version

If there is a new major version released, we'll need to create
a new branch for it. The `master` branch is always tracking the
latest Node.js version, so let's start there. Node 8 is released.

```sh
# update with any changes not present locally
git pull origin master

# Add the new version number in the readme and Makefile
# NODE_VERSION=8.0.0
# NPM_VERSION=5.0.0
# V8_VERSION=5.8.283.41
# IMAGE_TAG=8.x
vi README.md Makefile

# Make sure nothing broke
make all

# Then make the docker image tags and publish
make tag publish

# We've published the new release under the 'latest' tag.
# Commit and push that to github, then deal with the new branch.
git commit -a -m "(chore) release 8.x version"
git push origin master

# Now create the 8.x branch. Make sure all is good and publish to
# Docker hub.
git checkout -b 8.x
make tag publish

# The 8.x branch has all the commits we need
# right now, since we just made those changes on master.
# Just tag it with the node version and push.
git tag -s node-8.0.0 -m "Node.js 8.0.0 release"
git push origin 8.x --follow-tags
```

Don't forget the git tags. These are important and allow us to roll back
to any previously published version if necessary!
