# Makefile

# NOTE: The build breaks if realative paths are used, so we must base
# paths on the absolute path to the directory containing this file.
PROJROOT := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

LOCAL_CONFIG ?= Scripts/make/local.mk
-include ${LOCAL_CONFIG}

XCRUN ?= xcrun
XCODEBUILD ?= xcodebuild
CODESIGN ?= codesign
DOCC ?= docc
GIT ?= git
GH ?= gh
TAR ?= tar
PLUTIL ?= plutil

PRODUCT_NAME = Polling
VER := $(shell grep "^PROJECT_VERSION" Configs/Framework.xcconfig | cut -d = -f 2 | tr -d ' ')
TAG := $(VER)

SRCROOT = $(PROJROOT)/$(PRODUCT_NAME)
WORKSPACE = $(PRODUCT_NAME).xcworkspace
SCHEME = $(PRODUCT_NAME)

BUILD_DIR = Build
RELEASE_DIR = Release

BUILDROOT = $(PROJROOT)/$(BUILD_DIR)
OBJROOT = $(BUILDROOT)/objs
SYMROOT = $(BUILDROOT)/frameworks
ARCHROOT = $(BUILDROOT)/archives
XCFRWKROOT = $(BUILDROOT)/xcframeworks
SYMGRAPHROOT = $(BUILDROOT)/symgraphs
DOCROOT = $(BUILDROOT)/docs

export ENABLE_USER_SCRIPT_SANDBOXING = NO
MODULE_VERIFY ?= YES

all: xcframework

include Scripts/make/xcframework.mk
include Scripts/make/framework.mk
include Scripts/make/doc.mk
include Scripts/make/release.mk
include Scripts/make/apps.mk


gen-user-scripts-input-file-list: FORCE
	Scripts/gen-user-scripts-input-file-list


clean:
	-rm -rf Build

clean-all: clean doc-clean clean-release


.PHONY: FORCE
