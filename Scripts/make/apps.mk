# apps.mk

SWIFTUI_PRODUCT_NAME = SwiftUIApp
UIKIT_PRODUCT_NAME = UIKitApp

APP_VARIANT =

SWIFTUI_XCODEPROJ = Examples/$(SWIFTUI_PRODUCT_NAME)/$(SWIFTUI_PRODUCT_NAME)$(APP_VARIANT).xcodeproj
UIKIT_XCODEPROJ = Examples/$(UIKIT_PRODUCT_NAME)/$(UIKIT_PRODUCT_NAME)$(APP_VARIANT).xcodeproj

SWIFTUI_XCCONFIG = Configs/SwiftUIApp-TestFlight.xcconfig
UIKIT_XCCONFIG = Configs/UIKitApp-TestFlight.xcconfig

SWIFTUI_INFOPLIST = ../../Scripts/templates/SwiftUIApp-TestFlight-Info.plist
UIKIT_INFOPLIST = ../../Scripts/templates/UIKitApp-TestFlight-Info.plist

SWIFTUI_ARCHIVE = $(ARCHROOT)/$(SWIFTUI_PRODUCT_NAME)$(DEST_iOS_suffix)
UIKIT_ARCHIVE = $(ARCHROOT)/$(UIKIT_PRODUCT_NAME)$(DEST_iOS_suffix)

APP_ARCHIVES += $(SWIFTUI_ARCHIVE).xcarchive
APP_ARCHIVES += $(UIKIT_ARCHIVE).xcarchive

$(SWIFTUI_ARCHIVE).xcarchive: SCHEME = $(SWIFTUI_PRODUCT_NAME)
$(SWIFTUI_ARCHIVE).xcarchive:
	$(XCODEBUILD) archive -project $(SWIFTUI_XCODEPROJ) -scheme $(SCHEME) \
		-destination generic/platform=iOS -config $(CONFIG) \
		-xcconfig $(SWIFTUI_XCCONFIG) -archivePath $(SWIFTUI_ARCHIVE) \
		DEVELOPMENT_TEAM=$(APPLE_DEVELOPMENT_TEAM) \
		INFOPLIST_FILE=$(SWIFTUI_INFOPLIST)

$(UIKIT_ARCHIVE).xcarchive: SCHEME = $(UIKIT_PRODUCT_NAME)
$(UIKIT_ARCHIVE).xcarchive:
	$(XCODEBUILD) archive -project $(UIKIT_XCODEPROJ) -scheme $(SCHEME) \
		-destination generic/platform=iOS -config $(CONFIG) \
		-xcconfig $(UIKIT_XCCONFIG) -archivePath $(UIKIT_ARCHIVE) \
		DEVELOPMENT_TEAM=$(APPLE_DEVELOPMENT_TEAM) \
		INFOPLIST_FILE=$(UIKIT_INFOPLIST)

$(APP_ARCHIVES): CONFIG = Release

apps: $(APP_ARCHIVES)

clean-apps:
	rm -rf $(APP_ARCHIVES)
