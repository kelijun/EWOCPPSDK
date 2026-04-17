Pod::Spec.new do |s|

  s.name             = 'EWOCPPSDK'
  s.version          = '1.0.0'
  s.summary          = 'Eway OCPP Charging Station SDK.'
  s.description      = <<-DESC
                       EWOCPPSDK is a powerful library for EV charging station management.
                       DESC
                       
  s.homepage         = 'https://github.com/kelijun/EWOCPPSDK'
  

  s.license          = { :type => 'Commercial', :text => 'Copyright (c) 2026 Eway. All rights reserved. 商业授权，严禁反编译或未授权分发。' }
  
  s.author           = { 'keli' => '666@xilicun.com' }
  

  s.source           = { :git => 'https://github.com/kelijun/EWOCPPSDK.git', :tag => s.version.to_s }


  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.static_framework = true


  s.vendored_frameworks = 'EWOCPPSDK.xcframework'


  s.dependency 'EWBluetoothSDK', '~> 0.1.7'
  s.dependency 'MessagePacker', '~> 0.4.7'
  s.dependency 'CrcSwift', '~> 0.0.3'

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end