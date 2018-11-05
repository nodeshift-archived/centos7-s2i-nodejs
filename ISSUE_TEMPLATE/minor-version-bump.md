## New Node.js minor version bump

Use this issue template to report a minor version bump in Node.js.

New Node.js version number: <x.x.x>

### Tasks

Check out the branch for whatever version is being updated. E.g.

```
git checkout v8.x
```

All of the following tasks occur on this branch.

- [ ] Ensure a [published node-rpm](https://github.com/nodeshift/node-rpm/releases) for this version exists.
- [ ] Update versions.mk with the correct version number for `NODE_VERSION` and `NPM_VERSION`.
- [ ] Update releases.json and image-streams.centos7.json with new version information.

```
node-metadata -i <major-version> | jq '.' > releases.json
node-image-stream -f releases.json -i nodeshift/centos7-s2i-nodejs > image-streams.centos7.json
```

- [ ] Ensure that `make all` passes successfully.
- [ ] Tag the new release: `git tag -s -m 'Update to Node.js version 8.10.0' v8.10.0`
- [ ] Publish the release to docker hub (you will need to have `DOCKER_USER` and `DOCKER_PASS` in your environment).

```
make tag publish
```

- [ ] Finally, push your changes to github: `git push origin <branch> --follow-tags`.

