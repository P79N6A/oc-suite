#
# Be sure to run `pod lib lint test3-pod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'oc-foundation'
  s.version          = '0.1.0'
  s.summary          = 'Talk is cheap, show me the code.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Talk is cheap, show me the code.
                       DESC

  s.homepage         = 'https://github.com/fallending/test3-pod'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fallending' => 'fengzilijie@qq.com' }
  s.source           = { :git => 'https://github.com/fallending/test3-pod.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  #s.source_files = 'test3-pod/foundation/**/*'
  s.source_files = "foundation/*.{h,m}", "foundation/foundation/**/*.{h,m}", "foundation/macros/*.{h,m}", "foundation/system/**/*.{h,m,c}"
  
  # s.resource_bundles = {
  #   'test3-pod' => ['test3-pod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
