Pod::Spec.new do |s|
  s.name             = 'YoTestSDK'
  s.version          = '1.0.0'
  s.summary          = '友验 iOS SDK。'

  s.description      = <<-DESC
  友验 iOS SDK，基于虚拟机保护、设备特征识别和操作行为识别的新一代智能验证码，具备智能评分、抗 Headless、模拟伪装、针对恶意设备自动提升验证难度等多项安全措施，帮助开发者减少恶意攻击导致的数字资产损失，强力护航业务安全。
                       DESC

  s.homepage         = 'https://github.com/YoTest-team/YoTest-iOS-SDK'
  s.author           = { 'Darwel.Z' => 'x1aox1a45py@163.com' }
  s.source           = { :git => 'https://github.com/YoTest-team/YoTest-iOS-SDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.platform = :ios, '9.0'
  s.swift_version = "5.5"
  s.vendored_frameworks = "Product/YoTestSDK.xcframework"
end

