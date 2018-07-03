#
#  Be sure to run `pod spec lint oc-modules.podspec' to ensure this is a
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

  s.name         = "_Modules"
  s.version      = "0.0.2"
  s.summary      = "iOS 开发包 之 工具 库[Objective-C]"
  s.description  = <<-DESC
                   iOS 开发包 之 工具 库[Objective-C]
                   DESC
  s.homepage     = "https://github.com/fallending"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { '7' => 'fengzilijie@qq.com' }

  s.ios.deployment_target = '8.0'
  s.source       = { :git => 'https://github.com/fallending/oc-suite.git', :tag => s.version.to_s }

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.subspec 'Components' do |components|
    components.subspec 'QRCodeReader' do |qrCodeReader|
      qrCodeReader.source_files = "_Modules/Components/QRCodeReader/**/*.{h,m}"
      qrCodeReader.resources = "_Modules/Components/QRCodeReader/Resources/*.png"
    end

    # components.subspec 'Serializer' do |serializer|
    #   serializer.source_files = "_Tool/Network/Serializer/*.{h,m}"
    # end
  end

  s.subspec 'Services' do |services|
    services.subspec 'Assets' do |assets|
      assets.source_files = "_Modules/Services/Assets/**/*.{h,m}"
    end

    # services.subspec 'Serializer' do |serializer|
    #   serializer.source_files = "_Tool/Network/Serializer/*.{h,m}"
    # end
  end

end
