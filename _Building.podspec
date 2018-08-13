#
#  Be sure to run `pod spec lint oc-ui.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "_Building"
  s.version      = "0.2.0"
  s.summary      = "iOS 开发包 之 页面库 [Objective-C]"
  s.description  = <<-DESC
                   iOS 开发包 之 页面库 [Objective-C]
                   DESC

  s.homepage     = 'https://github.com/fallending'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { '7' => 'fengzilijie@qq.com' }
  s.source       = { :git => 'https://github.com/fallending/oc-suite.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.frameworks = 'UIKit'

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files = "_Building/*.{h,m}", "_Building/Core/**/*.{h,m}", "_Building/Template/**/*.{h,m}", "_Building/Base/**/*.{h,m}"
  # s.exclude_files = "Classes/Exclude"

end
