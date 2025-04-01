# Using the Swift Package Manager

Adding the SDK to a project with the Swift Package Manager

## Overview

You can add the Polling SDK to a project using the Xcode UI.

### Adding the Polling SDK to a Projecgt Using the Xcode UI

Choose `File` → `Add Package Dependencies…`

![Add Package Dependencies Menu Item](xcode-add-package-dep-menu)

In the field labeled `Search or Enter Package URL` paste the URL

```
https://github.com/PollingInc/polling-sdk-ios
```

![Package URL field](xcode-package-url)

Click `Add Package`. When the `Choose Package Products` dialog appears
choose either `PollingSDK` or `PollingSDK-Signed` by adding one to a
target. For the SDK you don't want to use choose `None` for its `Add
to Target` option.

![Choose Package Products](xcode-choose-package)

When you're satisfied with your package selection choose `Add Package`.
