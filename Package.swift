// swift-tools-version:5.5
import PackageDescription

let package = Package(
	name: "PollingSDK",
	platforms: [
		.iOS(.v12), .macCatalyst(.v13)
	],
	products: [
		.library(
			name: "PollingSDK",
			targets: ["PollingSDK"]
		),
		.library(
			name: "PollingSDK-Signed",
			targets: ["PollingSDK-Signed"]
		),
	],
	targets: [
		.binaryTarget(
			name: "PollingSDK",
			url: "https://github.com/pollinginc/polling-sdk-ios/releases/download/1.0.0-RC1/Polling.xcframework-swiftpm-1.0.0-RC1-unsigned.zip",
			checksum: "7e08ee61ac5fe1ebf9da3fd34cadb1d13f242d1c8be92ff682cb2dff60e7a128"
		),
		.binaryTarget(
			name: "PollingSDK-Signed",
			url: "https://github.com/pollinginc/polling-sdk-ios/releases/download/1.0.0-RC1/Polling.xcframework-swiftpm-1.0.0-RC1-signed.zip",
			checksum: "f545308c6d8adc667e97c0a373e03883d74681d98691051e230886c07eeb7d5d"
		),
	]
)
