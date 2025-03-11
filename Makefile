# Makefile

# NOTE: The build breaks if realative paths are used, so we must base
# paths on the absolute path to the directory containing this file.
PROJROOT := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

LOCAL_CONFIG ?= Scripts/make/local.mk
-include ${LOCAL_CONFIG}

XCODEBUILD ?= xcodebuild
CODESIGN ?= codesign

PRODUCT_NAME = Polling

SRCROOT = $(PROJROOT)/$(PRODUCT_NAME)
WORKSPACE = $(PRODUCT_NAME).xcworkspace
SCHEME = $(PRODUCT_NAME)

BUILD_DIR = Build
DIST_DIR = Dist

BUILDROOT = $(PROJROOT)/$(BUILD_DIR)
OBJROOT = $(BUILDROOT)/objs
SYMROOT = $(BUILDROOT)/frameworks
ARCHROOT = $(BUILDROOT)/archives
XCFRWKROOT = $(BUILDROOT)/xcframeworks


all: xcframework

include Scripts/make/xcframework.mk


gen-user-scripts-input-file-list: FORCE
	Scripts/gen-user-scripts-input-file-list


clean:
	-rm -rf Build


.PHONY: FORCE
