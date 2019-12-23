### DOCKER_IMAGE ###############################################################

IMAGES			?= alpine

# $(call IMAGES_RECIPE,$(IMAGES),$(TARGET))
define IMAGES_RECIPE
for IMAGE in $(1); do \
	cd $(CURDIR)/$${IMAGE}; \
	make $(2); \
done
endef

### MAKE_TARGETS ###############################################################

# Build all images
.PHONY: all
all: image

# Build all images
.PHONY: image
image:
	@$(call IMAGES_RECIPE,$(IMAGES),$@)

# Delete all running containers and work files
.PHONY: clean
clean:
	@$(call IMAGES_RECIPE,$(IMAGES),$@)

################################################################################
