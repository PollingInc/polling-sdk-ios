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
			name: "PollingSDK-Unsigned",
			targets: ["PollingSDK-Unsigned"]
		),
		.library(
			name: "PollingSDK-Signed",
			targets: ["PollingSDK-Signed"]
		),
	],
	targets: [
		.binaryTarget(
			name: "PollingSDK",
			url: "https://github.com/pollinginc/polling-sdk-ios/releases/download/__TAG__/Polling.xcframework-__TAG__-swiftpm-unsigned.zip",
			checksum: "__UNSIGNED_CHECKSUM__"
		),
		.binaryTarget(
			name: "PollingSDK-Unsigned",
			url: "https://github.com/pollinginc/polling-sdk-ios/releases/download/__TAG__/Polling.xcframework-__TAG__-swiftpm-unsigned.zip",
			checksum: "__UNSIGNED_CHECKSUM__"
		),
		.binaryTarget(
			name: "PollingSDK-Signed",
			url: "https://github.com/pollinginc/polling-sdk-ios/releases/download/__TAG__/Polling.xcframework-__TAG__-swiftpm-signed.zip",
			checksum: "__SIGNED_CHECKSUM__"
		),
	]
)
