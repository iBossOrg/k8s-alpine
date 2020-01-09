### DOCKER_IMAGE ###############################################################

IMAGE_VARIANTS		?= latest edge

# $(call IMAGE_VARIANTS_RECIPE,$(IMAGE_VARIANTS),$(TARGET))
define IMAGE_VARIANTS_RECIPE
for IMAGE_VARIANT in $(1); do \
	echo ; \
	echo "### k8s-alpine/$${IMAGE_VARIANT}"; \
	echo ; \
	cd $(CURDIR)/$${IMAGE_VARIANT}; \
	make $(2); \
done
endef

### MAKE_TARGETS ###############################################################

# Build all images and run tests
.PHONY: all
all: image

# Build all images and run tests
.PHONY: image
image:
	@$(call IMAGE_VARIANTS_RECIPE,$(IMAGE_VARIANTS),image clean)

# Pull images form Docker registry
.PHONY: docker-pull
docker-pull:
	-@$(call IMAGE_VARIANTS_RECIPE,$(IMAGE_VARIANTS),$@)

# Push images to Docker registry
.PHONY: docker-push
docker-push:
	@$(call IMAGE_VARIANTS_RECIPE,$(IMAGE_VARIANTS),$@)

# Prune Docker engine
.PHONY: docker-prune
docker-prune:
	@docker system prune -f

# Delete all running containers and work files
.PHONY: clean
clean:
	@$(call IMAGE_VARIANTS_RECIPE,$(IMAGE_VARIANTS),$@)

################################################################################
