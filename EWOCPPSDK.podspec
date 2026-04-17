Pod::Spec.new do |s|

  s.name             = 'EWOCPPSDK'
  s.version          = '1.0.0' # 每次发布新版本请修改这里
  s.summary          = 'Eway OCPP Charging Station SDK.'
  s.description      = <<-DESC
                       EWOCPPSDK 提供了完整的 OCPP 充电桩本地化管理与控制解决方案。
                       支持蓝牙连接、局域网 OTA 升级、参数配置及实时数据监控。
                       DESC
                       
  s.homepage         = 'https://github.com/kelijun/EWOCPPSDK' # 替换为你的主页或仓库地址
  

  s.license          = { :type => 'Commercial', :text => 'Copyright (c) 2026 Eway. All rights reserved. 商业授权，严禁反编译或未授权分发。' }
  
  s.author           = { 'keli' => 'your_email@example.com' } # 替换为你的邮箱
  

  s.source           = { :git => 'https://github.com/kelijun/EWOCPPSDK.git', :tag => s.version.to_s }


  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'
  s.static_framework = true


  s.vendored_frameworks = 'EWOCPPSDK.xcframework'


  s.dependency 'EWBluetoothSDK', '~> 0.1.7'
  s.dependency 'MessagePacker', '~> 0.4.7'
  s.dependency 'CrcSwift', '~> 0.0.3'
end