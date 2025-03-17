# xcframework.mk

DEST_iOS_suffix=-iphoneos
DEST_iOS_Simulator_suffix=-iphonesimulator
DEST_Mac_Catalyst_suffix=-maccatalyst


# Archives

ARCHIVE_IOS = $(ARCHROOT)/$(PRODUCT_NAME)$(DEST_iOS_suffix)
ARCHIVE_IOS_SIMULATOR = $(ARCHROOT)/$(PRODUCT_NAME)$(DEST_iOS_Simulator_suffix)
ARCHIVE_MAC_CATALYST = $(ARCHROOT)/$(PRODUCT_NAME)$(DEST_Mac_Catalyst_suffix)

ARCHIVES += $(ARCHIVE_IOS).xcarchive
ARCHIVES += $(ARCHIVE_IOS_SIMULATOR).xcarchive
ARCHIVES += $(ARCHIVE_MAC_CATALYST).xcarchive

# NOTE: The man page for `xcodebuild` says `archive` "archive[s] a
# scheme from the build root (SYMROOT)." But it doesn't appear to
# actually operate on SYMROOT. SYMROOT does not seem to be needed. In
# fact, setting the SYMROOT randomly breaks the build.

$(ARCHIVE_IOS).xcarchive:
	$(XCODEBUILD) archive -workspace $(WORKSPACE) -scheme $(SCHEME) \
		-destination generic/platform=iOS \
		-config $(CONFIG) -archivePath $(ARCHIVE_IOS)

$(ARCHIVE_IOS_SIMULATOR).xcarchive:
	$(XCODEBUILD) archive -workspace $(WORKSPACE) -scheme $(SCHEME) \
		-destination generic/platform='iOS Simulator' \
		-config $(CONFIG) -archivePath $(ARCHIVE_IOS_SIMULATOR)


$(ARCHIVE_MAC_CATALYST).xcarchive:
	$(XCODEBUILD) archive -workspace $(WORKSPACE) -scheme $(SCHEME) \
		-destination generic/platform=macOS,variant='Mac Catalyst' \
		-config $(CONFIG) -archivePath $(ARCHIVE_MAC_CATALYST)

$(ARCHIVES): CONFIG = Release
$(ARCHIVES): FORCE


# XCFrameworks

XCFRAMEWORK = $(PRODUCT_NAME).xcframework

XCFRAMEWORK_UNSIGNED = $(XCFRWKROOT)/unsigned/$(XCFRAMEWORK)
XCFRAMEWORK_SIGNED = $(XCFRWKROOT)/signed/$(XCFRAMEWORK)

XCFRAMEWORK_ARGS += -archive $(ARCHIVE_IOS).xcarchive -framework $(FRAMEWORK)
XCFRAMEWORK_ARGS += -archive $(ARCHIVE_IOS_SIMULATOR).xcarchive -framework $(FRAMEWORK)
XCFRAMEWORK_ARGS += -archive $(ARCHIVE_MAC_CATALYST).xcarchive -framework $(FRAMEWORK)

# NOTE: We can't use file name rule because we have to delete it
# before `create-xcframework` will succeed.
xcframework: xcframework-unsigned

# Only build the signed XCFramework when the distribution identity is
# defined.
ifdef APPLE_DISTRIBUTION_IDENTITY
xcframework: xcframework-signed
endif

xcframework-unsigned: $(ARCHIVES)
	-rm -rf $(XCFRAMEWORK_UNSIGNED)
	$(XCODEBUILD) -create-xcframework $(XCFRAMEWORK_ARGS) \
		-output $(XCFRAMEWORK_UNSIGNED)

xcframework-signed: $(ARCHIVES)
	-rm -rf $(XCFRAMEWORK_SIGNED)
	$(XCODEBUILD) -create-xcframework $(XCFRAMEWORK_ARGS) \
		-output $(XCFRAMEWORK_SIGNED)
	$(CODESIGN) --timestamp -s $(APPLE_DISTRIBUTION_IDENTITY) $(XCFRAMEWORK_SIGNED)

$(XCFRAMEWORK_UNSIGNED): xcframework-unsigned
$(XCFRAMEWORK_SIGNED): xcframework-signed
