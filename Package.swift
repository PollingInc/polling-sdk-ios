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
			url: "https://github.com/pollinginc/polling-sdk-ios/releases/download/1.0.0-RC2/Polling.xcframework-swiftpm-1.0.0-RC2-unsigned.zip",
			checksum: "e9abf2393268422e86c46a87d643028d33b1e58629d2a968b5001918ff4bd0e7"
		),
		.binaryTarget(
			name: "PollingSDK-Signed",
			url: "https://github.com/pollinginc/polling-sdk-ios/releases/download/1.0.0-RC2/Polling.xcframework-swiftpm-1.0.0-RC2-signed.zip",
			checksum: "cf7b67e600e9c46239da16a31c1d62cc9ed32c629360bbc93ca9d13f3a46f403"
		),
	]
)
