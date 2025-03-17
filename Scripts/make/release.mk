# release.mk

VERFILE = $(RELEASE_DIR)/v$(VER)
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


prepare-release: $(RELEASE_DIR) $(BINARIES)
	touch $(VERFILE)
	Scripts/release.rb v$(VER) $(RELNOTES)

publish-release:


clean-release:
	-rm -rf Release
