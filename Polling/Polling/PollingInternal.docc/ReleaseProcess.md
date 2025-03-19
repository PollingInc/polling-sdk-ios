# Release Process

Steps necessary for producing SDK releases.

## Overview

Before attempting a release setup the project as described in
<doc:CodeSigning>. Then follow the steps in the section
<doc:#Making-a-Release>.

## Making a Release

Create a release of the SDK.

### Update the Version Number

Open `Configs/Framework.xcconfig` locate the `PROJECT_VERSION`
variable and bump the version to reflect the nature of the
release. The version is in _MAJOR.MINOR.PATCH_ format. The version
string is described in <doc:VersionScheme>.

```
PROJECT_VERSION = 1.0.0
```

### Commit the Version Bump

Commit the version bump and all other changes. Remove or stash
anything in the worktree until `git status` shows "nothing to commit,
working tree clean".

### Prepare the Release

Run `make prepare-release` to build the XCFrameworks, build the docs,
package the binaries, generate release notes, makes a draft GitHub
release.

### Edit the Release Notes and Sanity Checks

Open the generated release notes at `Release/notes.md` and make edits
such as removing entries like "fix typo" or "forgot to add file",
etc. Fix spelling, grammar, and edit for conciseness and clarity.

- Edit `Release/notes.md`
- Check that the signed and unsigned XCFramework were created and
packaged.
- Check the public and internal documentation
- Modify `Release/title.txt` if necessary

Use `make edit-release` to update the title or release notes.

### Publish the Release

Run `make publish-release` when everything looks good.
