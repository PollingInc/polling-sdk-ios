# release.mk


VERFILE = $(RELEASE_DIR)/v$(VER)
RELTITLE = $(RELEASE_DIR)/title.txt
RELNOTES = $(RELEASE_DIR)/notes.md

UNSIGNED_TARBALL = $(RELEASE_DIR)/$(PRODUCT_NAME).xcframework-v$(VER)-unsigned.tar.gz
UNSIGNED_ZIP = $(RELEASE_DIR)/$(PRODUCT_NAME).xcframework-v$(VER)-unsigned.zip
SIGNED_TARBALL = $(RELEASE_DIR)/$(PRODUCT_NAME).xcframework-v$(VER)-signed.tar.gz
SIGNED_ZIP = $(RELEASE_DIR)/$(PRODUCT_NAME).xcframework-v$(VER)-signed.zip

SWIFTPM_UNSIGNED_ZIP = $(RELEASE_DIR)/$(PRODUCT_NAME).xcframework-v$(VER)-swiftpm-unsigned.zip
SWIFTPM_SIGNED_ZIP = $(RELEASE_DIR)/$(PRODUCT_NAME).xcframework-v$(VER)-swiftpm-signed.zip

BINARIES += $(UNSIGNED_TARBALL)
BINARIES += $(UNSIGNED_ZIP)
BINARIES += $(SIGNED_TARBALL)
BINARIES += $(SIGNED_ZIP)

SWIFTPM_BINARIES = $(SWIFTPM_UNSIGNED_ZIP) $(SWIFTPM_SIGNED_ZIP)

ALL_BINARIES = $(BINARIES) $(SWIFTPM_BINARIES)

UNSIGNED_DIR = $(BUILD_DIR)/xcframeworks/unsigned
SIGNED_DIR = $(BUILD_DIR)/xcframeworks/signed

SWIFTPM_UNSIGNED_DIR = $(BUILD_DIR)/xcframeworks/swiftpm/unsigned
SWIFTPM_SIGNED_DIR = $(BUILD_DIR)/xcframeworks/swiftpm/signed

UNSIGNED_XCFRWK = $(UNSIGNED_DIR)/$(XCFRAMEWORK)
SIGNED_XCFRWK = $(SIGNED_DIR)/$(XCFRAMEWORK)

SWIFTPM_UNSIGNED_XCFRWK = $(SWIFTPM_UNSIGNED_DIR)/$(XCFRAMEWORK)
SWIFTPM_SIGNED_XCFRWK = $(SWIFTPM_SIGNED_DIR)/$(XCFRAMEWORK)

$(SWIFTPM_UNSIGNED_XCFRWK): $(XCFRAMEWORK_SWIFTPM_UNSIGNED)
$(SWIFTPM_SIGNED_XCFRWK): $(XCFRAMEWORK_SWIFTPM_SIGNED)


$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)


$(BINARIES): $(RELEASE_DIR)
$(SWIFTPM_BINARIES): $(RELEASE_DIR)
$(ALL_BINARIES): $(RELEASE_DIR)

$(UNSIGNED_TARBALL): $(UNSIGNED_XCFRWK)
	$(TAR) -C $(UNSIGNED_DIR) -a -cf $@ $(XCFRAMEWORK)

$(UNSIGNED_ZIP): $(UNSIGNED_XCFRWK)
	$(TAR) -C $(UNSIGNED_DIR) --format=zip -a -cf $@ $(XCFRAMEWORK)

$(SIGNED_TARBALL): $(SIGNED_XCFRWK)
	$(TAR) -C $(SIGNED_DIR) -a -cf $@ $(XCFRAMEWORK)

$(SIGNED_ZIP): $(SIGNED_XCFRWK)
	$(TAR) -C $(SIGNED_DIR) --format=zip -a -cf $@ $(XCFRAMEWORK)

$(SWIFTPM_SIGNED_ZIP): $(SWIFTPM_SIGNED_XCFRWK)
	$(TAR) -C $(SWIFTPM_SIGNED_DIR) --format=zip -a -cf $@ $(XCFRAMEWORK)

$(SWIFTPM_UNSIGNED_ZIP): $(SWIFTPM_UNSIGNED_XCFRWK)
	$(TAR) -C $(SWIFTPM_UNSIGNED_DIR) --format=zip -a -cf $@ $(XCFRAMEWORK)

commit-release: export PRODUCT_NAME := $(PRODUCT_NAME)
commit-release: export PROJECT_VERSION := $(VER)
commit-release: export CONFIGURATION := Release
commit-release: export BUILD_FOR_SWIFTPM := YES
commit-release: $(RELEASE_DIR) $(SWIFTPM_BINARIES)
	Scripts/release.rb commit v$(VER) $(RELTITLE) $(RELNOTES) $(SWIFTPM_BINARIES)

prepare-release: export PRODUCT_NAME := $(PRODUCT_NAME)
prepare-release: export PROJECT_VERSION := $(VER)
prepare-release: export CONFIGURATION := Release
prepare-release: $(RELEASE_DIR) $(BINARIES)
	touch $(VERFILE)
	Scripts/release.rb prepare v$(VER) $(RELTITLE) $(RELNOTES) $(ALL_BINARIES)

edit-release: export PRODUCT_NAME := $(PRODUCT_NAME)
edit-release: export PROJECT_VERSION := $(VER)
edit-release: export CONFIGURATION := Release
edit-release:
	Scripts/release.rb edit v$(VER) $(RELTITLE) $(RELNOTES) $(ALL_BINARIES)

publish-release: export PRODUCT_NAME := $(PRODUCT_NAME)
publish-release: export PROJECT_VERSION := $(VER)
publish-release: export CONFIGURATION := Release
publish-release:
	Scripts/release.rb publish v$(VER) $(RELTITLE) $(RELNOTES) $(ALL_BINARIES)


clean-release:
	-rm -rf Release
