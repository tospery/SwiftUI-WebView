Pod::Spec.new do |s|
  s.name             = 'SwiftUI-WebView-Hi'
  s.version          = '0.3.0.1'
  s.summary          = 'A SwiftUI component to use WKWebView'
  s.description      = <<-DESC
						A SwiftUI component to use WKWebView.
                       DESC
  s.homepage         = 'https://github.com/tospery/SwiftUI-WebView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YangJianxiang' => 'tospery@gmail.com' }
  s.source           = { :git => 'https://github.com/tospery/SwiftUI-WebView.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.swift_version = '5.3'
  s.ios.deployment_target = '16.0'
  s.frameworks = 'Foundation', 'UIKit'
  
  s.source_files = 'Sources/**/*'
  
end
