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

ARCHIVE_INFO_PLIST = $(ARCHIVE_IOS).xcarchive/Products/Library/Frameworks/Polling.framework/Info.plist

# NOTE: The man page for `xcodebuild` says `archive` "archive[s] a
# scheme from the build root (SYMROOT)." But it doesn't appear to
# actually operate on SYMROOT. SYMROOT does not seem to be needed. In
# fact, setting the SYMROOT randomly breaks the build.

$(ARCHIVE_IOS).xcarchive:
	$(XCODEBUILD) archive -workspace $(WORKSPACE) -scheme $(SCHEME) \
		-destination generic/platform=iOS \
		-config $(CONFIG) -archivePath $(ARCHIVE_IOS) \
		ENABLE_MODULE_VERIFIER=$(MODULE_VERIFY) \
		ENABLE_USER_SCRIPT_SANDBOXING=NO

$(ARCHIVE_IOS_SIMULATOR).xcarchive:
	$(XCODEBUILD) archive -workspace $(WORKSPACE) -scheme $(SCHEME) \
		-destination generic/platform='iOS Simulator' \
		-config $(CONFIG) -archivePath $(ARCHIVE_IOS_SIMULATOR) \
		ENABLE_MODULE_VERIFIER=$(MODULE_VERIFY) \
		ENABLE_USER_SCRIPT_SANDBOXING=NO


$(ARCHIVE_MAC_CATALYST).xcarchive:
	$(XCODEBUILD) archive -workspace $(WORKSPACE) -scheme $(SCHEME) \
		-destination generic/platform=macOS,variant='Mac Catalyst' \
		-config $(CONFIG) -archivePath $(ARCHIVE_MAC_CATALYST) \
		ENABLE_MODULE_VERIFIER=$(MODULE_VERIFY) \
		ENABLE_USER_SCRIPT_SANDBOXING=NO

$(ARCHIVES): CONFIG = Release
$(ARCHIVES): FORCE


# XCFrameworks

XCFRAMEWORK = $(PRODUCT_NAME).xcframework

XCFRAMEWORK_UNSIGNED = $(XCFRWKROOT)/unsigned/$(XCFRAMEWORK)
XCFRAMEWORK_SIGNED = $(XCFRWKROOT)/signed/$(XCFRAMEWORK)

XCFRAMEWORK_ARGS += -archive $(ARCHIVE_IOS).xcarchive -framework $(FRAMEWORK)
XCFRAMEWORK_ARGS += -archive $(ARCHIVE_IOS_SIMULATOR).xcarchive -framework $(FRAMEWORK)
XCFRAMEWORK_ARGS += -archive $(ARCHIVE_MAC_CATALYST).xcarchive -framework $(FRAMEWORK)


XCFRAMEWORK_UNSIGNED_INFO_PLIST = $(XCFRAMEWORK_UNSIGNED)/Info.plist
XCFRAMEWORK_SIGNED_INFO_PLIST = $(XCFRAMEWORK_SIGNED)/Info.plist

rm-old-xcframeworks:
	-rm -rf $(XCFRAMEWORK_UNSIGNED) $(XCFRAMEWORK_SIGNED)

# # NOTE: We can't use file name rule because we have to delete it
# # before `create-xcframework` will succeed.
xcframework: rm-old-xcframeworks

xcframework: $(XCFRAMEWORK_UNSIGNED)

# Only build the signed XCFramework when the distribution identity is
# defined.
ifdef APPLE_DISTRIBUTION_IDENTITY
xcframework: $(XCFRAMEWORK_SIGNED)
endif

$(XCFRAMEWORK_UNSIGNED): $(ARCHIVES)
	$(XCODEBUILD) -create-xcframework $(XCFRAMEWORK_ARGS) -output $@
	Scripts/set-xcframework-vers $(PLUTIL) $(ARCHIVE_INFO_PLIST) $@/Info.plist

$(XCFRAMEWORK_SIGNED): $(ARCHIVES)
	$(XCODEBUILD) -create-xcframework $(XCFRAMEWORK_ARGS) -output $@
	Scripts/set-xcframework-vers $(PLUTIL) $(ARCHIVE_INFO_PLIST) $@/Info.plist
	$(CODESIGN) --timestamp -s $(APPLE_DISTRIBUTION_IDENTITY) $@
