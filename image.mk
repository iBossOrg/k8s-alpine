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
all: build start wait logs test

# Delete all running containers and work files, build an image and run tests
.PHONY: image
image: _clean all

### BUILD_TARGETS ##############################################################

# Build an image with using Docker layer caching
.PHONY: build
build: docker-build

# Build an image without using Docker layer caching
.PHONY: rebuild
rebuild: docker-rebuild

### EXECUTOR_TARGETS ###########################################################

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

# Delete all containers and work files
.PHONY: clean
clean: docker-clean

# Helper that gives the opportunity to call the clean target twice
.PHONY: _clean
_clean:
	@$(MAKE) clean

### DOCKER_IMAGE_MK ############################################################

MK_DIR			?= $(PROJECT_DIR)/../Mk
include $(MK_DIR)/docker.image.mk

################################################################################