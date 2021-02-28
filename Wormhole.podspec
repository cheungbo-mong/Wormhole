#
# Be sure to run `pod lib lint Wormhole.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Wormhole'
  s.version          = '0.1.0'
  s.summary          = 'Message passing between apps and extensions.'
  s.homepage         = 'https://github.com/vencewill/Wormhole'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vance Will' => 'vancewilll@icloud.com' }
  s.source           = { :git => 'https://github.com/vencewill/Wormhole.git', :tag => s.version.to_s }
  s.requires_arc = true

  s.default_subspec = 'Core'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '3.0'
  
  s.ios.frameworks = 'CoreServices', 'Foundation', 'WatchConnectivity'
  s.osx.frameworks = 'CoreServices', 'Foundation'
  s.watchos.frameworks = 'CoreServices', 'Foundation', 'WatchConnectivity'
  
  s.subspec 'Core' do |core|
      core.source_files = 'Sources/Wormhole/**/*.swift'
    end
end
