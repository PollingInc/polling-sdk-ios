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
			url: "https://github.com/pollinginc/polling-sdk-ios/releases/download/1.0.0/Polling.xcframework-swiftpm-1.0.0-unsigned.zip",
			checksum: "4f30a99ec2428f588ec88a62e76f5c31b4896d672b42d33f6edca39ece82a698"
		),
		.binaryTarget(
			name: "PollingSDK-Signed",
			url: "https://github.com/pollinginc/polling-sdk-ios/releases/download/1.0.0/Polling.xcframework-swiftpm-1.0.0-signed.zip",
			checksum: "d4985ca9ee8b13cc002106df29d0a4257be5dd2c48b99aa070c6d843d0b43ad1"
		),
	]
)
