# Publishing the `centos7-s2i-nodejs` images to Docker Hub

There are a couple of different scenarios that would require newly
published images. The obvious case is when there is a new Node.js
version released. But sometimes we need to push a new image because
there was a bug fix in the builder image. Or we changed something
in the `node-rpm` distribution.

Follow these steps to publish. In all cases, you should have `DOCKER_USER`
and `DOCKER_PASS` defined in your environment.

```sh
$ export DOCKER_USER=lanceball
$ export DOCKER_PASS=xxxxxxxxx
```

## Bug fixes to the builder image

When we need to publish new images because the underlying builder
(and not Node.js itself) has changed. The process is pretty simple.

Check out the master branch and be sure you are up to date.

```sh
$ git fetch upstream
$ git rebase upstream/master master
```

Make your code changes, then test and commit them. The `master` branch
can be published without a tag since it does not track a specific release.

```sh
$ git push upstream master
$ make tag publish
```

Now you need to update all of the versions we are supporting with these
changes. Currently, that means the `8.x` and `9.x` branches. Check out
each branch, apply the changes, test, commit and publish.

```sh
$ git checkout 8.x
$ git cherry-pick <sha> # get the commit that you applied in master
```

If the cherry-picking fails, you'll need to figure out what went wrong
and fix it. You can run `git status` to see where there were problems.
If you need to, then, make these fixes, then use `git add` and
`git cherry-pick --continue` to finish applying them.

Each of these branches should be tagged with the Node.js version number
and a suffix signifying the update for this release. For example, if the
current 9.x release is `9.4.0` and you are making updates to the `9.x`
branch, you should look for the most current 9.x tag and increment it.

```sh
$ git tag | grep node-9.4.0 # Find the most recent release (e.g. node-9.4.0-2)
$ git tag node-9.4.0-3 # Increment the version suffix
$ git push upstream 9.x --follow-tags # Push the tag upstream
```

## New minor or patch-level release

Let's say that Node.js version 9.10.1 is released and we are currently
publishing 9.10.0. This is a patch level version bump. Note that these
steps will be the same for a minor release, for example, in
this case, if Node.js 9.11.0 is released.

Take the following steps to publish the latest version.

```sh
# switch to the branch being published
git checkout 9.x

# update with any changes not present locally
git pull upstream 9.x
git rebase upstream/9.x 9.x

# Change the version numbers in versions.mk
# NODE_VERSION=9.10.1
# NPM_VERSION=5.6.0

# Make sure nothing broke
make all

# Then make the docker image tags and publish
make tag publish

# If everything looks good, commit, tag and push to github
git commit -a -m "chore: update to Node.js 9.10.1"
git tag -s -m "Node.js 9.10.1 release" node-9.10.1
git push upstream 9.x --follow-tags
```

## New major version

If there is a new major version released, we'll need to create
a new branch for it. The `master` branch is always tracking the
latest Node.js version, so let's start there. Node 10 is released.

```sh
# update with any changes not present locally
git pull upstream master

# Create a new branch for the version
git checkout -b v10.x

# Add the new version number in versions.mk and Makefile
# and commit your changes on this new branch

# Make sure nothing broke
make all

# Then make the docker image tags and publish
make tag publish

# The 10.x branch has all the commits we need.
# Tag it with the node version and push.
git tag -s -m "Node.js 10.0.0 release" node-10.0.0
git push upstream 10.x --follow-tags

```

Don't forget the git tags. These are important and allow us to roll back
to any previously published version if necessary!
