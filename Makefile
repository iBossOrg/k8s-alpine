SUBDIRS		?= latest edge
TARGET		?= image

# Build and test all images
.PHONY: all images
all images: $(SUBDIRS)

# Build and test the image
.PHONY: $(SUBDIRS)
$(SUBDIRS):
	@echo
	@echo "===> alpine:$@"
	@echo
	@cd $@; make $(TARGET)

# Pull all images from Docker registry
.PHONY: pull
pull:
	@$(MAKE) all TARGET=pull

# Publish all images into Docker registry
.PHONY: publish
publish:
	@$(MAKE) all TARGET=publish

# Clean all images
.PHONY: clean
clean:
	@$(MAKE) all TARGET=clean
