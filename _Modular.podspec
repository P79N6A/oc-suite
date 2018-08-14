#
#  Be sure to run `pod spec lint oc-modular.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "_Modular"
  s.version      = "0.1.0"
  s.summary      = "iOS 开发包 之 模块化机制 [Objective-C]"
  s.description  = <<-DESC
                   iOS 开发包 之 模块化机制 [Objective-C]
                   DESC
  s.homepage     = "https://github.com/fallending"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { '7' => 'fengzilijie@qq.com' }

  s.ios.deployment_target = '8.0'
  s.source       = { :git => 'https://github.com/fallending/oc-suite.git', :tag => s.version.to_s }
  # s.source_files  = "Classes", "Classes/**/*.{h,m}"
  # s.exclude_files = "Classes/Exclude"

  # s.requires_arc = true

  s.source_files = "_Modular/**/*.{h,m}"

end
