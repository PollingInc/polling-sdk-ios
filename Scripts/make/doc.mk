# doc.mk

POLLING_BUILD_SUBDIR=$(DOC_OBJROOT)/$(PRODUCT_NAME).build/Release-iphoneos/$(PRODUCT_NAME).build

ARCH = arm64
SYMGRAPH_TRIPLE = $(ARCH)-apple-ios

SYMGRAPH_DIR_PUBLIC = $(SYMGRAPHROOT)/Public
SYMGRAPH_DIR_CLANG = $(SYMGRAPH_DIR_PUBLIC)/clang/$(SYMGRAPH_TRIPLE)
SYMGRAPH_DIR_SWIFT = $(SYMGRAPH_DIR_PUBLIC)/swift/$(SYMGRAPH_TRIPLE)

SYMGRAPH_DIR_INTERNAL = $(SYMGRAPHROOT)/Internal

SYMGRAPH_DIRS += $(SYMGRAPH_DIR_PUBLIC)
SYMGRAPH_DIRS += $(SYMGRAPH_DIR_CLANG)
SYMGRAPH_DIRS += $(SYMGRAPH_DIR_SWIFT)
SYMGRAPH_DIRS += $(SYMGRAPH_DIR_INTERNAL)

SYMGRAPH_CLANG = $(SYMGRAPH_DIR_CLANG)/$(PRODUCT_NAME).symbols.json
SYMGRAPH_SWIFT = $(SYMGRAPH_DIR_SWIFT)/$(PRODUCT_NAME).symbols.json
SYMGRAPH_INTERNAL = $(SYMGRAPH_DIR_INTERNAL)/$(PRODUCT_NAME).symbols.json

SDK_PATH := $(shell $(XCRUN) --sdk iphoneos --show-sdk-path)

HEADER_ROOT = $(DOC_SYMROOT)/Release-iphoneos/$(PRODUCT_NAME).framework/Headers
INTERNAL_HEADER_ROOT = $(SRCROOT)/$(PRODUCT_NAME)/Internal

HEADER_SEARCH_ARGS += -iquote $(POLLING_BUILD_SUBDIR)/$(PRODUCT_NAME)-generated-files.hmap
HEADER_SEARCH_ARGS += -I $(POLLING_BUILD_SUBDIR)/$(PRODUCT_NAME)-own-target-headers.hmap
HEADER_SEARCH_ARGS += -I $(POLLING_BUILD_SUBDIR)/$(PRODUCT_NAME)-all-target-headers.hmap
HEADER_SEARCH_ARGS += -iquote $(POLLING_BUILD_SUBDIR)/$(PRODUCT_NAME)-project-headers.hmap
HEADER_SEARCH_ARGS += -I $(DOC_FRAMEWORK_RELEASE_DIR)/include
HEADER_SEARCH_ARGS += -I $(POLLING_BUILD_SUBDIR)/DerivedSources-normal/$(ARCH)
HEADER_SEARCH_ARGS += -I $(POLLING_BUILD_SUBDIR)/DerivedSources/$(ARCH)
HEADER_SEARCH_ARGS += -I $(POLLING_BUILD_SUBDIR)/DerivedSources
HEADER_SEARCH_ARGS += -F $(DOC_FRAMEWORK_RELEASE_DIR)

EXTRA_ARGS += -fmodules
EXTRA_ARGS += -fobjc-arc
EXTRA_ARGS += -fmodule-name=Polling
EXTRA_ARGS += -Wno-nullability-completeness

PUBLIC_DOCC_SOURCE_BUNDLE = $(SRCROOT)/Polling/Polling.docc
INTERNAL_DOCC_SOURCE_BUNDLE = $(SRCROOT)/Polling/PollingInternal.docc
DOCC_PUBLIC_PORT ?= 8080
DOCC_INTERNAL_PORT ?= 9090

# docs build dirs used for preview
DOCS_DIR_PUBLIC = $(DOCROOT)/Public
DOCS_DIR_INTERNAL = $(DOCROOT)/Internal

# docs worktree used for convert
DOCS_WORKTREE = $(PROJROOT)/Docs

export DOCC_JSON_PRETTYPRINT = YES


# Symgraph

symgraph-public: symgraph-clang symgraph-swift
symgraph-clang: $(SYMGRAPH_CLANG)
symgraph-swift: $(SYMGRAPH_SWIFT)
symgraph-internal: $(SYMGRAPH_INTERNAL)

$(SYMGRAPH_DIRS):
	mkdir -p $@

$(SYMGRAPH_CLANG): HEADERS = $(shell find $(HEADER_ROOT) -name "*.h")
$(SYMGRAPH_CLANG): $(DOC_FRAMEWORK) FORCE
	$(XCRUN) clang -extract-api --product-name=$(PRODUCT_NAME) \
		--pretty-sgf -o $@ -isysroot $(SDK_PATH) \
		-F $(SDK_PATH)/System/Library/Frameworks \
		$(HEADER_SEARCH_ARGS) $(EXTRA_ARGS) \
		-x objective-c-header $(HEADERS)

$(SYMGRAPH_SWIFT): $(DOC_FRAMEWORK) $(SYMGRAPH_DIR_SWIFT) FORCE
	xcrun swift-symbolgraph-extract -sdk $(SDK_PATH) \
		-target $(SYMGRAPH_TRIPLE) -pretty-print \
		-F $(DOC_FRAMEWORK_RELEASE_DIR) \
		-module-name $(PRODUCT_NAME) \
		-output-dir $(SYMGRAPH_DIR_SWIFT)

$(SYMGRAPH_INTERNAL): HEADERS = $(shell find $(HEADER_ROOT) -name "*.h")
$(SYMGRAPH_INTERNAL): HEADERS += $(shell find $(INTERNAL_HEADER_ROOT) -name "*.h")
$(SYMGRAPH_INTERNAL): HEADERS += $(shell find $(INTERNAL_HEADER_ROOT) -name "*.m")
$(SYMGRAPH_INTERNAL): $(DOC_FRAMEWORK) FORCE
	$(XCRUN) clang -extract-api --product-name=$(PRODUCT_NAME) \
		--pretty-sgf -o $@ -isysroot $(SDK_PATH) \
		-F $(SDK_PATH)/System/Library/Frameworks \
		$(HEADER_SEARCH_ARGS) $(EXTRA_ARGS) \
		-x objective-c-header $(HEADERS)

clean-symgraph: clean-symgraph-public clean-symgraph-internal
clean-symgraph-public: FORCE
	rm -rf $(SYMGRAPH_DIR_PUBLIC)
clean-symgraph-internal: FORCE
	rm -rf $(SYMGRAPH_DIR_INTERNAL)


# Preview

# NOTE: If you see "An error was encountered while compiling
# documentation" while previewing the docs, check to make sure another
# preview server isn't running.

$(DOCROOT):
	mkdir -p $@

doc-preview-public: DOCC_SOURCE_BUNDLE = $(PUBLIC_DOCC_SOURCE_BUNDLE)
doc-preview-public: SYMGRAPH_ROOT = $(SYMGRAPH_DIR_PUBLIC)
doc-preview-public: DOCS_ROOT = $(DOCS_DIR_PUBLIC)
doc-preview-public: $(SYMGRAPH_CLANG) $(SYMGRAPH_SWIFT) $(DOCROOT)
	$(XCRUN) $(DOCC) preview $(DOCC_SOURCE_BUNDLE) \
		--port $(DOCC_PUBLIC_PORT) \
		--fallback-display-name $(PRODUCT_NAME) \
		--fallback-bundle-identifier com.polling.Polling \
		--fallback-bundle-version 1.0.0 \
		--additional-symbol-graph-dir $(SYMGRAPH_ROOT) \
		--experimental-enable-custom-templates \
		--output-dir $(DOCS_ROOT)

doc-preview-internal: DOCC_SOURCE_BUNDLE = $(INTERNAL_DOCC_SOURCE_BUNDLE)
doc-preview-internal: SYMGRAPH_ROOT = $(SYMGRAPH_DIR_INTERNAL)
doc-preview-internal: DOCS_ROOT = $(DOCS_DIR_INTERNAL)
doc-preview-internal: $(SYMGRAPH_INTERNAL) $(DOCROOT)
	$(XCRUN) $(DOCC) preview $(DOCC_SOURCE_BUNDLE) \
		--port $(DOCC_INTERNAL_PORT) \
		--fallback-display-name $(PRODUCT_NAME) \
		--fallback-bundle-identifier com.polling.Polling \
		--fallback-bundle-version 1.0.0 \
		--additional-symbol-graph-dir $(SYMGRAPH_ROOT) \
		--experimental-enable-custom-templates \
		--output-dir $(DOCS_ROOT)


# Convert for hosting on GitHub

$(DOCS_WORKTREE):
	$(GIT) fetch
	$(GIT) worktree add --checkout $(DOCS_WORKTREE) origin/docs

doc-convert: doc-convert-public doc-convert-internal

GH_BASE_PATH_PUBLIC = /polling-sdk-ios/public
CONVERT_EXTRA_ARGS_PUBLIC += --hosting-base-path $(GH_BASE_PATH_PUBLIC)
doc-convert-public: CONVERT_EXTRA_ARGS = $(CONVERT_EXTRA_ARGS_PUBLIC)
doc-convert-public: DOCC_SOURCE_BUNDLE = $(PUBLIC_DOCC_SOURCE_BUNDLE)
doc-convert-public: SYMGRAPH_ROOT = $(SYMGRAPH_DIR_PUBLIC)
doc-convert-public: DOCS_ROOT = $(DOCS_WORKTREE)/docs/public
doc-convert-public: $(SYMGRAPH_CLANG) $(SYMGRAPH_SWIFT) $(DOCS_WORKTREE)
	$(XCRUN) $(DOCC) convert $(DOCC_SOURCE_BUNDLE) \
		--fallback-display-name $(PRODUCT_NAME) \
		--fallback-bundle-identifier com.polling.Polling \
		--fallback-bundle-version 1.0.0 \
		--additional-symbol-graph-dir $(SYMGRAPH_ROOT) \
		--experimental-enable-custom-templates \
		$(CONVERT_EXTRA_ARGS) \
		--output-dir $(DOCS_ROOT)

GH_BASE_PATH_INTERNAL = /polling-sdk-ios/internal
CONVERT_EXTRA_ARGS_INTERNAL += --hosting-base-path $(GH_BASE_PATH_INTERNAL)
doc-convert-internal: CONVERT_EXTRA_ARGS = $(CONVERT_EXTRA_ARGS_INTERNAL)
doc-convert-internal: DOCC_SOURCE_BUNDLE = $(INTERNAL_DOCC_SOURCE_BUNDLE)
doc-convert-internal: SYMGRAPH_ROOT = $(SYMGRAPH_DIR_INTERNAL)
doc-convert-internal: DOCS_ROOT = $(DOCS_WORKTREE)/docs/internal
doc-convert-internal: $(SYMGRAPH_INTERNAL) $(DOCS_WORKTREE)
	$(XCRUN) $(DOCC) convert $(DOCC_SOURCE_BUNDLE) \
		--fallback-display-name $(PRODUCT_NAME) \
		--fallback-bundle-identifier com.polling.Polling \
		--fallback-bundle-version 1.0.0 \
		--additional-symbol-graph-dir $(SYMGRAPH_ROOT) \
		--experimental-enable-custom-templates \
		$(CONVERT_EXTRA_ARGS) \
		--output-dir $(DOCS_ROOT)

doc-clean:
	-$(GIT) worktree remove $(DOCS_WORKTREE)
