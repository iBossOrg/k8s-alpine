### BASE_IMAGE #################################################################

BASE_IMAGE_NAME		?= $(DOCKER_NAME)
BASE_IMAGE_TAG		?= $(DOCKER_IMAGE_TAG)

### DOCKER_IMAGE ###############################################################

DOCKER_VENDOR		?= iboss
DOCKER_NAME		?= alpine
DOCKER_IMAGE_TAG	?= latest
DOCKER_IMAGE_DESC	?= Alpine Linux base image modified for Kubernetes friendliness.
DOCKER_IMAGE_URL	?= https://github.com/iBossOrg/k8s-alpine

### DOCKER_TEST ################################################################

OS_RELEASE		?= $(BASE_IMAGE_TAG)
TEST_VARS		+= OS_RELEASE

### MAKE_TARGETS ###############################################################

# Build an image and run tests
.PHONY: all
all: lint build start wait logs test

# Delete all running containers and work files, build an image and run tests
.PHONY: image
image: all
	@$(MAKE) clean

# Lint project files
.PHONY: lint
lint: docker-lint shellcheck

# Lint Docker files
.PHONY: docker-lint
docker-lint:
	@echo "+++ hadolint help: https://github.com/hadolint/hadolint#rules" > /dev/stderr
	@set -x; \
	docker run --rm \
	--volume $(PROJECT_DIR)/Dockerfile:/Dockerfile \
	--volume $(PROJECT_DIR)/.hadolint.yaml:/.hadolint.yaml \
	hadolint/hadolint hadolint Dockerfile

# Lint shell scripts
.PHONY: shellcheck
shellcheck:
	@echo "+++ shellcheck help: https://github.com/koalaman/shellcheck/wiki/Checks" > /dev/stderr
	@for FILE in $(shell cd $(PROJECT_DIR); ls rootfs/service/* rootfs/entrypoint/*); do ( \
		set -x; \
		docker run --rm --volume "$(PROJECT_DIR):/mnt" koalaman/shellcheck:stable $${FILE} \
	); done

# Pull all images from the Docker Registry
.PHONY: pull
pull: docker-pull

# Publish the image into the Docker Registry
.PHONY: publish
publish: docker-push

# Build an image with using Docker layer caching
.PHONY: build
build: docker-build

# Build an image without using Docker layer caching
.PHONY: rebuild
rebuild: docker-rebuild

# Show the make variables
.PHONY: vars
vars: docker-makevars

# Delete the containers and then run them fresh
.PHONY: run up
run up: docker-up

# Create the containers
.PHONY: create
create: docker-create

# Start the containers
.PHONY: start
start: docker-start

# Wait for the containers to start
.PHONY: wait
wait: docker-wait

# List running containers
.PHONY: ps
ps: docker-ps

# Show the container logs
.PHONY: logs
logs: docker-logs

# Follow the container logs
.PHONY: tail
tail: docker-logs-tail

# Run the shell in the container
.PHONY: sh
sh: docker-shell

# Run the tests
.PHONY: test
test: docker-test

# Run the shell in the test container
.PHONY: tsh
tsh:
	@$(MAKE) test TEST_CMD=/bin/bash RSPEC_FORMAT=documentation

# Restart the containers
.PHONY: restart
restart: docker-restart

# Stop the containers
.PHONY: stop
stop: docker-stop

# Delete the containers
.PHONY: down rm
down rm: docker-rm

# Delete the containers and working files
.PHONY: clean
clean: docker-clean

### DOCKER_IMAGE_MK ############################################################

MK_DIR			?= $(PROJECT_DIR)/../Mk
include $(MK_DIR)/docker.image.mk

################################################################################
