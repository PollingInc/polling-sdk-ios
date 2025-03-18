# Configure Code Signing

Configure Project for Code Signing

## Overview

Apple in the future may require all third-party SDKs to be signed by
the SDK developer. To ensure we're prepared, we produce both signed
and unsigned XCFrameworks.

Once, after cloning the repo the project needs to be configured for
code signing.

## Setup the Project for Code Signing

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
