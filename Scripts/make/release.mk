# release.mk

VERFILE = $(RELEASE_DIR)/v$(VER)
RELNOTES = $(RELEASE_DIR)/notes.md

$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)

prepare-release: $(RELEASE_DIR)
	touch $(VERFILE)
	Scripts/release.rb v$(VER) $(RELNOTES)

publish-release:
