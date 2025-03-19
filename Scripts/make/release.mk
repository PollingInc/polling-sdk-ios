# release.mk


VERFILE = $(RELEASE_DIR)/v$(VER)
RELTITLE = $(RELEASE_DIR)/title.txt
RELNOTES = $(RELEASE_DIR)/notes.md

UNSIGNED_TARBALL = $(RELEASE_DIR)/$(PRODUCT_NAME).xcframework-v$(VER)-unsigned.tar.gz
UNSIGNED_ZIP = $(RELEASE_DIR)/$(PRODUCT_NAME).xcframework-v$(VER)-unsigned.zip
SIGNED_TARBALL = $(RELEASE_DIR)/$(PRODUCT_NAME).xcframework-v$(VER)-signed.tar.gz
SIGNED_ZIP = $(RELEASE_DIR)/$(PRODUCT_NAME).xcframework-v$(VER)-signed.zip

BINARIES += $(UNSIGNED_TARBALL)
BINARIES += $(UNSIGNED_ZIP)
BINARIES += $(SIGNED_TARBALL)
BINARIES += $(SIGNED_ZIP)

UNSIGNED_DIR = $(BUILD_DIR)/xcframeworks/unsigned
SIGNED_DIR = $(BUILD_DIR)/xcframeworks/signed

UNSIGNED_XCFRWK = $(UNSIGNED_DIR)/$(XCFRAMEWORK)
SIGNED_XCFRWK = $(SIGNED_DIR)/$(XCFRAMEWORK)


$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)


$(BINARIES): $(RELEASE_DIR)

$(UNSIGNED_TARBALL): $(UNSIGNED_XCFRWK)
	$(TAR) -C $(UNSIGNED_DIR) -a -cf $@ $(XCFRAMEWORK)

$(UNSIGNED_ZIP): $(UNSIGNED_XCFRWK)
	$(TAR) -C $(UNSIGNED_DIR) --format=zip -a -cf $@ $(XCFRAMEWORK)

$(SIGNED_TARBALL): $(SIGNED_XCFRWK)
	$(TAR) -C $(SIGNED_DIR) -a -cf $@ $(XCFRAMEWORK)

$(SIGNED_ZIP): $(SIGNED_XCFRWK)
	$(TAR) -C $(SIGNED_DIR) --format=zip -a -cf $@ $(XCFRAMEWORK)


prepare-release: export PRODUCT_NAME := $(PRODUCT_NAME)
prepare-release: export PROJECT_VERSION := $(VER)
prepare-release: export CONFIGURATION := Release
prepare-release: $(RELEASE_DIR) $(BINARIES)
	touch $(VERFILE)
	Scripts/release.rb prepare v$(VER) $(RELTITLE) $(RELNOTES)

edit-release: export PRODUCT_NAME := $(PRODUCT_NAME)
edit-release: export PROJECT_VERSION := $(VER)
edit-release: export CONFIGURATION := Release
edit-release:
	Scripts/release.rb edit v$(VER) $(RELTITLE) $(RELNOTES)

publish-release: export PRODUCT_NAME := $(PRODUCT_NAME)
publish-release: export PROJECT_VERSION := $(VER)
publish-release: export CONFIGURATION := Release
publish-release:
	Scripts/release.rb publish v$(VER) $(RELTITLE) $(RELNOTES)


clean-release:
	-rm -rf Release
