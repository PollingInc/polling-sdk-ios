# Manually Adding the SDK

Adding the SDK without a package manager

## Overview

Download a release from GitHub and add the XCFramework to the project

### Download a release

Pick the most recent release from
[](https://github.com/PollingInc/polling-sdk-ios/releases) and
download one of the XCFramework archives

### Add the XCFramework to the project

Select the project item from the Project Navigator.

![Project selected](select-project)

Select the app from the Target list.

![Target selected](select-target)

Scroll down to the "Frameworks, Libraries, and Embedded Content"
section.

![Frameworks, Libraries, and Embedded Content section](frameworks-section)

Locate the `Polling.xcframework` in Finder.

![Frameworks folder in Finder](finder-xcframework)

Drag `Polling.xcframework` from Finder to the "Frameworks, Libraries,
and Embedded Content" section in Xcode.

![Dragging xcframework](drag-xcframework)
