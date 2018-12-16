# Makes the centos7-s2i-nodejs image.
make all

# Login into openshift docker registry.
docker login -u `oc whoami` -p `oc whoami -t` 172.30.1.1:5000

# Creates a new project.
oc new-project nodeshift

# Creates a tag on openshift docker registry based on the local created image.
docker tag nodeshift/centos7-s2i-nodejs:11.x 172.30.1.1:5000/nodeshift/centos7-s2i-nodejs:11.x

# Pushes the image to the openshift docker registry.
docker push 172.30.1.1:5000/nodeshift/centos7-s2i-nodejs:11.x

# Creates a new app based on the pushed image.
oc new-app 172.30.1.1:5000/nodeshift/centos7-s2i-nodejs:11.x~https://github.com/nodeshift/nodejs-rest-http

# Exposes to confirm that the app was successfully deployed.
timeout 1m oc expose svc/nodejs-rest-http
