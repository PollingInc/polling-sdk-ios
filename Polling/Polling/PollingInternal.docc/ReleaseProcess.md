# Release Process

Steps necessary for producing SDK releases.

## Overview

Follow these steps

## Setup the Project

Onetime project setup.

### Configure Code Signing

Create a Makefile at `Scripts/make/local.mk`.

```makefile
APPLE_DEVELOPMENT_TEAM ?= <team-id>
APPLE_DISTRIBUTION_IDENTITY ?= '<distribution-identity>'
APPLE_DEVELOPMENT_IDENTITY ?= '<development-identity>'
```

The value for `APPLE_DEVELOPMENT_TEAM` is not
quoted. `APPLE_DISTRIBUTION_IDENTITY` and `APPLE_DEVELOPMENT_IDENTITY`
values must be quoted.

> Note: `APPLE_DISTRIBUTION_IDENTITY` is the only required variable
> for code signing.

This file is ignored by git and will need to be recreated or copied
for every repo clone used for generating releases.

These values may also be set as environment variable making the build
CI friendly.

### Configure Script Sandboxing

You must disable user script sandboxing to build releases. Scripts
that are sandboxed can not operate on their own git repo and
`Scripts/xcode-gen-vers` will print an error and stop the release
build if sandboxing is enabled.

Create or open a build configuration file at `Configs/Local.xcconfig`
and insert the following configuration variable.

```
ENABLE_USER_SCRIPT_SANDBOXING = NO
```

This file is ignored by git and will need to be recreated or copied
for every repo clone used for generating releases.

## Making a Release

Create a release of the SDK.

### Update the Version Number

Open `Configs/Framework.xcconfig` locate the `PROJECT_VERSION`
variable and bump the version. The version is in _MAJOR.MINOR.PATCH_
format.

```
PROJECT_VERSION = 1.0.0
```

The version string may contain extra info affixed to the end. The
extra info **must** begin with a hyphen. For a beta release one might
set the version string as follows:

```
PROJECT_VERSION = 1.0.0-Beta1
```

Or for a release candidate one might set the version string as follows:

```
PROJECT_VERSION = 1.0.0-RC1
```

The build automatically embeds the version info in the SDK's binary
and outputs it to the console on the first use of the SDK.

Additionally the build automatically inserts the version info into
each of the frameworks' `Info.plist` and into the XCFrameworks'
`Info.plist`, so that the SDK may be identified without running in an
app.

The format of the version info follows

```
Polling vMAJOR.MINOR.PATCH[-EXTRA]:BRANCH@SHORT_HASH:CONFIG[:dirty]
```

- term MAJOR: major version number
- term MINOR: minor version number
- term PATCH: patch version number
- term EXTRA: extra version info
- term BRANCH: the current git branch
- term SHORT_HASH: the git short hash
- term CONFIG: the build configuration, one of `Debug` or `Release`
- term dirty: the value `:dirty` is appended if there are uncommitted
  changes or untracked files in the repo

Here is an examples of the full version string:

```
Polling v1.0.0-RC1:master@c0532f3:Debug:dirty
```

The build automatically inserts the version string in the `Info.plist`
of every `.framework` and `.xcframework` under the key
`POLSDKVersion`.

### Commit the Version Bump

Commit the version bump and all other changes. Remove or stash
anything in worktree until `git status` shows "nothing to commit,
working tree clean".

### Prepare the Release

Run `make prepare-release` to build the XCFrameworks, build the docs,
package the binaries, generate release notes, makes a draft GitHub
release.

### Edit the Release Notes and Sanity Checks

Open the generated release notes at `Release/notes.md` and make edits
such as removing entries like "fix typo" or "forgot to add file",
etc. Fix spelling, grammar, and edit for conciseness and clarity.

- Check that the signed and unsigned XCFramework were created and
packaged.
- Check the public and internal documentation

### Publish the Release

Run `make publish-release` when everything looks good.
