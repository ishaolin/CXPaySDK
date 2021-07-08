#
# Be sure to run `pod lib lint CXPaySDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do | s |
    s.name             = 'CXPaySDK'
    s.version          = '1.0'
    s.summary          = '支付封装'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
  
    s.description      = '支付宝、微信支付的封装'

    s.homepage         = 'https://github.com/ishaolin/CXPaySDK'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'wshaolin' => 'ishaolin@163.com' }
    s.source           = { :git => 'https://github.com/ishaolin/CXPaySDK.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '9.0'
    
    s.vendored_libraries = [
      'CXPaySDK/ThirdLib/Libs/*.a'
    ]
    
    s.vendored_frameworks = [
      'CXPaySDK/ThirdLib/Frameworks/*.framework',
    ]
    
    s.resources = [
      'CXPaySDK/ThirdLib/Resources/*.bundle',
    ]
    
    s.frameworks = [
      'CoreGraphics',
      'QuartzCore',
      'CoreTelephony',
      'SystemConfiguration',
      'CoreText',
      'CoreMotion',
      'CFNetwork',
      'Security',
      'PassKit'
    ]
    
    s.libraries = [
      'z',
      'c++',
      'sqlite3.0'
    ]
    
    s.public_header_files = [
      'CXPaySDK/Classes/**/*.h',
      'CXPaySDK/ThirdLib/Headers/**/*.h'
    ]
    s.source_files = [
      'CXPaySDK/Classes/**/*',
      'CXPaySDK/ThirdLib/Headers/**/*.h'
    ]
    
    s.dependency 'WechatOpenSDK', '1.8.7.1'
    s.dependency 'CXFoundation'
end
