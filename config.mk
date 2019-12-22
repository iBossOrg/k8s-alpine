### PROJECT ####################################################################

PROJECT_NAME		?= k8s-alpine

### BASE_IMAGE #################################################################

BASE_IMAGE_NAME		?= $(DOCKER_NAME)
BASE_IMAGE_TAG		?= $(DOCKER_IMAGE_TAG)

### DOCKER_IMAGE ###############################################################

DOCKER_VENDOR		?= iboss
DOCKER_NAME		?= alpine
DOCKER_IMAGE_TAG	?= latest
DOCKER_IMAGE_DESC	?= Alpine Linux base image modified for Kubernetes friendliness.
DOCKER_IMAGE_URL	?= https://github.com/iBossOrg/k8s-alpine

################################################################################
