Pod::Spec.new do |s|
  s.name = "PollingSDK"
  s.version = "__VERSION__"
  s.summary = "Summary of Polling SDK"
  s.description = <<-DESC
Poll and survey your users using this SDK form Polling.com
DESC

  s.homepage = "https://polling.com"
  s.license = { :type => "Copyright", :text => "Copyright © 2025 Polling.com" }
  s.author = "Polling.com"
  s.documentation_url = "https://pollinginc.github.io/polling-sdk-ios"

  # Not sure how to specify Mac Catalyst
  # s.osx.deployment_target = "10.15"
  s.ios.deployment_target = "12.0"

  s.source = {
    :http => "https://github.com/pollinginc/polling-sdk-ios/releases/download/__TAG__/Polling.xcframework-__TAG__-unsigned.zip"
  }
  s.vendored_frameworks = "Polling.xcframework"

  # Unsigned Subspec
  s.subspec 'Unsigned' do |sp|
    sp.source = {
      :http => "https://github.com/pollinginc/polling-sdk-ios/releases/download/__TAG__/Polling.xcframework-__TAG__-unsigned.zip"
    }
    sp.vendored_frameworks = "Polling.xcframework"
  end

  # Signed Subspec
  s.subspec 'Signed' do |sp|
    sp.source = {
      :http => "https://github.com/pollinginc/polling-sdk-ios/releases/download/__TAG__/Polling.xcframework-__TAG__-signed.zip",
    }
    sp.vendored_frameworks = "Polling.xcframework"
  end
end
