FROM=openshift/base-centos7

# These values are changed in each version branch
# This is the only place they need to be changed
# other than the README.md file.
NODE_VERSION=4.8.3
NPM_VERSION=2.15.11
V8_VERSION=4.5.103.47
IMAGE_TAG=4.x

TARGET=bucharestgold/centos7-s2i-nodejs:$(IMAGE_TAG)

.PHONY: all
all: build squash test

.PHONY: build
build:
	docker build \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg NPM_VERSION=$(NPM_VERSION) \
	--build-arg V8_VERSION=$(V8_VERSION) \
	-t $(TARGET) .

.PHONY: squash
squash: 
	docker-squash -f $(FROM) $(TARGET) -t $(TARGET)

.PHONY: test
test: build squash
	 BUILDER=$(TARGET) NODE_VERSION=$(NODE_VERSION) ./test/run.sh

.PHONY: clean
clean:
	docker rmi `docker images $(TARGET) -q`

.PHONY: publish
publish: all
	docker login --username $(DOCKER_USER) --password $(DOCKER_PASS)
	docker push $(TARGET)
