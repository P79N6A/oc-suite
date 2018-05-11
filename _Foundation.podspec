#
# Be sure to run `pod lib lint test3-pod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = '_Foundation'
  s.version          = '0.2.0'
  s.summary          = 'iOS 开发包 之 基础库[Objective-C]'
  s.description      = <<-DESC
                       iOS 开发包 之 基础库[Objective-C]
                       DESC

  s.homepage         = 'https://github.com/fallending'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '7' => 'fengzilijie@qq.com' }
  s.source           = { :git => 'https://github.com/fallending/oc-suite.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = "_Foundation/*.{h,m}", "_Foundation/Core/**/*.{h,m,c}", "_Foundation/Macros/*.{h,m,c}"
  
  # s.resource_bundles = {
  #   'test3-pod' => ['test3-pod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
