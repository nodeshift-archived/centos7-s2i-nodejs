FROM=centos/s2i-core-centos7
IMAGE_NAME=bucharestgold/centos7-s2i-nodejs

# These values are changed in each version branch
# This is the only place they need to be changed
# other than the README.md file.
include versions.mk

TARGET=$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: all
all: build squash test

build: Dockerfile s2i contrib
	docker build \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg NPM_VERSION=$(NPM_VERSION) \
	-t $(TARGET) .

.PHONY: squash
squash:
	if [ -z $(SKIP_SQUASH) ] ; then docker-squash -f $(FROM) $(TARGET) -t $(TARGET); fi


.PHONY: test
test: build
	 BUILDER=$(TARGET) NODE_VERSION=$(NODE_VERSION) ./test/run.sh

.PHONY: clean
clean:
	docker rmi `docker images $(TARGET) -q`

.PHONY: tag
tag:
	if [ ! -z $(LTS_TAG) ]; then docker tag $(TARGET) $(IMAGE_NAME):$(LTS_TAG); fi
	docker tag $(TARGET) $(IMAGE_NAME):$(NODE_VERSION)

.PHONY: publish
publish: all
	echo $(DOCKER_PASS) | docker login -u $(DOCKER_USER) --password-stdin
	docker push $(TARGET)
	docker push $(IMAGE_NAME):$(NODE_VERSION)
	if [ ! -z $(LTS_TAG) ]; then docker push $(IMAGE_NAME):$(LTS_TAG); fi
