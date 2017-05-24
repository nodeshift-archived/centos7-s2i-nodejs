FROM=openshift/base-centos7
IMAGE_NAME=centos7-s2i-nodejs
NAMESPACE=lanceball
NODE_VERSION=7.10.0
IMAGE_TAG=latest
TARGET=$(NAMESPACE)/$(IMAGE_NAME):$(IMAGE_TAG)

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
	docker rmi `docker images $(NAMESPACE)/$(IMAGE_NAME)-testapp -q`

.PHONY: publish
publish: all
	docker login --username $(DOCKER_USER) --password $(DOCKER_PASS)
	docker push $(TARGET)
