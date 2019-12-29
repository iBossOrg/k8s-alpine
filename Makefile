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
.PHONY: all image
all image:
	@$(call IMAGES_RECIPE,$(IMAGES),all)

# Delete all running containers and work files
.PHONY: clean
clean:
	@$(call IMAGES_RECIPE,$(IMAGES),$@)

################################################################################
