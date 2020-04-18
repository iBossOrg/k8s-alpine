SUBDIRS		?= latest edge
TARGET		?= all

# Build and test all images
.PHONY: all
all:
	@$(MAKE) $(SUBDIRS) TARGET=all

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

# Build and test the image
.PHONY: $(SUBDIRS)
$(SUBDIRS):
	@cd $@; make docker-version $(TARGET)
