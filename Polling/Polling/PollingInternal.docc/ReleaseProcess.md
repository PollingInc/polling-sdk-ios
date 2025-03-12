# Release Process

Steps necessary for producing SDK releases.

## Overview

Follow these steps

## Configuring for Code Signing

Create a Makefile at `Scripts/make/local.mk`. This file is ignored by
git and will need to be recreated or copied for every repo clone used
for generating releases.

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

These values may also be set as environment variable making the build
CI friendly.

## Update Version Number

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

The version info is embedded in the SDK's binary and printed on the
first use of the SDK. The version info is additionally inserted into
the framework's `Info.plist` so that the SDK may be identified without
running in an app. The format of the version info

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
