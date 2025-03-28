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
			url: "https://github.com/pollinginc/polling-sdk-ios/releases/download/v1.0.0-RC/Polling.xcframework-swiftpm-v1.0.0-RC-unsigned.zip",
			checksum: "2c9ef3a9bfe4c3e2383a06225213fc207c2254b70521cea082a292c25b55694d"
		),
		.binaryTarget(
			name: "PollingSDK-Signed",
			url: "https://github.com/pollinginc/polling-sdk-ios/releases/download/v1.0.0-RC/Polling.xcframework-swiftpm-v1.0.0-RC-signed.zip",
			checksum: "28883fcb3d899d3b49c6b3a7951beef615cd110e7773353c82a7ed94c89de94a"
		),
	]
)
