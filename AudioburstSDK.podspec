Pod::Spec.new do |s|
  s.name             = 'AudioburstSDK'
  s.version          = '0.0.2'
  s.summary          = 'Official SDK from Audioburst'

  s.homepage         = 'https://github.com/audioburst-labs/AudioburstSDK-iOS'
  s.license          = { :type => 'Custom'}
  s.author           = { 'Audioburst' => 'alex.kobylak@audioburst.com' }
  s.source           = { :git => 'https://github.com/audioburst-labs/AudioburstSDK-iOS.git', :tag => s.version.to_s }

  s.platform = :ios
  s.ios.deployment_target = '12.0'
  s.swift_version = "5.0"
  s.requires_arc = true
  s.source_files = '*/*.swift'

  s.dependency 'AudioburstMobileLibrary', '~> 0.0.21'

  # PlayerCore
   s.subspec 'AudioburstPlayerCore' do |sp|
     sp.source_files  = 'PlayerCore/*.swift', 'Shared/*/*.swift', 'Shared/*.swift'
   end
end
