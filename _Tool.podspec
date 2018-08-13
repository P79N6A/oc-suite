#
#  Be sure to run `pod spec lint oc-tool.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "_Tool"
  s.version      = "0.1.15"
  s.summary      = "iOS 开发包 之 工具库 [Objective-C]"
  s.description  = <<-DESC
                   iOS 开发包 之 工具库 [Objective-C]
                   DESC
  s.homepage     = "https://github.com/fallending"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { '7' => 'fengzilijie@qq.com' }

  s.ios.deployment_target = '8.0'
  s.source       = { :git => 'https://github.com/fallending/oc-suite.git', :tag => s.version.to_s }
  # s.source_files  = "Classes", "Classes/**/*.{h,m}"
  # s.exclude_files = "Classes/Exclude"

  # s.requires_arc = true

  s.subspec 'Cache' do |cache|
    cache.source_files = "_Tool/Cache/**/*.{h,m}"
  end

  s.subspec 'HttpMock' do |httpmock|
    httpmock.source_files = '_Tool/HttpMock/**/*.{h,m}'
  end

  s.subspec 'NetworkLit' do |networklit|
    networklit.source_files = "_Tool/NetworkLit/**/*.{h,m}"
  end

  s.subspec 'Network' do |network|
    # network.source_files = "tool/network/reachability/*.{h,m}"
    network.subspec 'Reachability' do |reachability|

      reachability.source_files = "_Tool/Network/Reachability/*.{h,m}"

    end

    network.subspec 'Serializer' do |serializer|

      serializer.source_files = "_Tool/Network/Serializer/*.{h,m}"

    end

  end

  s.subspec 'Database' do |database|
    database.source_files = "_Tool/Database/**/*.{h,m}"
  end

  s.subspec 'NoSQL' do |nosql|
    nosql.source_files = "_Tool/NoSQL/**/*.{h,m}"
  end

  s.subspec 'Utility' do |utility|
    utility.source_files = "_Tool/Utility/**/*.{h,m,mm,c}"
    utility.libraries = "c++"
    utility.dependency "ZipArchive"
  end

  s.subspec 'Image' do |image|
    image.source_files = "_Tool/Image/**/*.{h,m}"
  end

  s.subspec 'Log' do |log|
    log.source_files = "_Tool/Log/**/*.{h,m}"
  end

  s.subspec 'Date' do |date|
    date.source_files = "_Tool/Date/**/*.{h,m}"
  end

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "c++"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
