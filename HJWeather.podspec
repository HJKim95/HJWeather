#
# Be sure to run `pod lib lint HJWeather.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HJWeather'
  s.version          = '0.1.5'
  s.summary          = 'Helps to use weather information in Korea'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Helps to use weather information in Korea, included weather and dust information.
                       DESC

  s.homepage         = 'https://github.com/HJKim95/HJWeather'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HJKim95' => '25ephipany@naver.com' }
  s.source           = { :git => 'https://github.com/HJKim95/HJWeather.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.source_files = 'Classes/**/*'
  
  # s.resource_bundles = {
  #   'HJWeather' => ['HJWeather/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit'
   s.dependency 'Alamofire'
   s.dependency 'SwiftyJSON'
end
