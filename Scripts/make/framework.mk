# framework.mk

DEST += iOS
DEST += iOS_Simulator
DEST += Mac_Catalyst

PLATFORM_iOS=iOS
PLATFORM_iOS_Simulator='iOS Simulator'
PLATFORM_Mac_Catalyst=macOS

VARIANT_Mac_Catalyst='Mac Catalyst'

COMMA=,
DESTARGS := $(foreach v,$(DEST),\
	-destination \
	generic/platform=$(PLATFORM_$(strip $(v)))$(if $(VARIANT_$(strip $(v)))\
	,$(COMMA)variant=$(VARIANT_$(strip $(v)))))


# Frameworks

FRAMEWORK = $(PRODUCT_NAME).framework

FRAMEWORK_DEBUG_PATHS = $(foreach v,$(DEST),\
	$(SYMROOT)/Debug$(DEST_$(v)_suffix)/$(FRAMEWORK))

FRAMEWORK_IOS_RELEASE = $(SYMROOT)/Release$(DEST_iOS_suffix)/$(FRAMEWORK)
FRAMEWORK_IOS_SIMULATOR_RELEASE = $(SYMROOT)/Release$(DEST_iOS_Simulator_suffix)/$(FRAMEWORK)
FRAMEWORK_MAC_CATALYST_RELEASE = $(SYMROOT)/Release$(DEST_Mac_Catalyst_suffix)/$(FRAMEWORK)

FRAMEWORK_RELEASE_PATHS += FRAMEWORK_IOS_RELEASE
FRAMEWORK_RELEASE_PATHS += FRAMEWORK_IOS_SIMULATOR_RELEASE
FRAMEWORK_RELEASE_PATHS += FRAMEWORK_MAC_CATALYST_RELEASE

# NOTE: We don't use file name based rules because xcodebuild creates
# multiple frameworks with multiple architectures and this prevents us
# from having to `lipo` together the final frameworks.
framework: framework-debug framework-release

framework-debug: CONFIG = Debug
framework-debug:
	$(XCODEBUILD) -workspace $(WORKSPACE) -scheme $(SCHEME) \
		-config $(CONFIG) $(DESTARGS) \
		OBJROOT=$(OBJROOT) SYMROOT=$(SYMROOT)

framework-release: CONFIG = Release
framework-release:
	$(XCODEBUILD) -workspace $(WORKSPACE) -scheme $(SCHEME) \
		-config $(CONFIG) $(DESTARGS) \
		OBJROOT=$(OBJROOT) SYMROOT=$(SYMROOT) \
		ENABLE_USER_SCRIPT_SANDBOXING=NO

$(FRAMEWORK_DEBUG_PATHS): framework-debug
$(FRAMEWORK_RELEASE_PATHS): framework-release


# Doc Framework

DOC_OBJROOT = $(DOCROOT)/objs
DOC_SYMROOT = $(DOCROOT)/frameworks
DOC_FRAMEWORK = $(DOC_SYMROOT)/Release$(DEST_iOS_suffix)/$(FRAMEWORK)

# NOTE: Only build for one destination and disable the module verifer
# for fast builds when building the docs. We also force the framework
# to build, so docs always build with the latest changes.
$(DOC_FRAMEWORK): CONFIG = Release
$(DOC_FRAMEWORK): FORCE
	$(XCODEBUILD) -workspace $(WORKSPACE) -scheme $(SCHEME) \
		-config $(CONFIG) -destination generic/platform=iOS \
		OBJROOT=$(DOC_OBJROOT) SYMROOT=$(DOC_SYMROOT) \
		ENABLE_MODULE_VERIFIER=NO ENABLE_USER_SCRIPT_SANDBOXING=NO

doc-framework: $(DOC_FRAMEWORK)
