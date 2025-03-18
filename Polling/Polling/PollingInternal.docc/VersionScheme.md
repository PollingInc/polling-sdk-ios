# Versioning Scheme

Format of the SDK version string

## Overview

The SDK uses the standard versioning scheme. The version string is in
_MAJOR.MINOR.PATCH_ format.

```
PROJECT_VERSION = 1.0.0
```

The version string may contain extra info affixed to the end. The
extra info **must** begin with a hyphen and **must not** contain a
period. For a beta release one might set the version string as
follows:

```
PROJECT_VERSION = 1.0.0-Beta1
```

Or for a release candidate one might set the version string as
follows:

```
PROJECT_VERSION = 1.0.0-RC1
```

> Important: The extra version info **must** begin with a hyphen.

> Warning: The extra version info **must not** contain a period.


## Identifying Builds

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
