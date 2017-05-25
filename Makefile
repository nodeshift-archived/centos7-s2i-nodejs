FROM=openshift/base-centos7

NODE_VERSION=7.10.0
IMAGE_TAG=7.x
TARGET=bucharestgold/centos7-s2i-nodejs:$(IMAGE_TAG)

.PHONY: all
all: build squash test

.PHONY: build
build:
	docker build -t $(TARGET) .

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
