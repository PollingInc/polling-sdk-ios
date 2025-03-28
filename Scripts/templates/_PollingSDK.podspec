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
    :http => "https://github.com/pollinginc/polling-sdk-ios/releases/download/__TAG__/Polling.xcframework-cocoapods-__TAG__.zip"
  }
  s.default_subspec = 'Unsigned'

  # NOTE: The users Xcode build will fail without this.
  s.pod_target_xcconfig = { 'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO' }

  # Unsigned Subspec
  s.subspec 'Unsigned' do |sp|
    sp.vendored_frameworks = "unsigned/Polling.xcframework"
  end

  # Signed Subspec
  s.subspec 'Signed' do |sp|
    sp.vendored_frameworks = "signed/Polling.xcframework"
  end
end
