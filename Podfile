platform :ios, '10.0'
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

target "Quickride" do
  project 'Quickride.xcodeproj'
  pod 'Alamofire', '4.8.1'
  pod 'GoogleMaps'
  pod 'XCGLogger'
  pod 'Moscapsule', :git => 'https://github.com/flightonary/Moscapsule.git'
  pod 'OpenSSL-Universal', '1.0.2.13'
  pod 'ObjectMapper'
  pod 'Polyline'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'RevealMenuController'
  pod 'UIFloatLabelTextField'
  pod 'MRCountryPicker'
  pod 'TrueSDK'
  pod 'ReachabilitySwift', '4.3.0'
  pod 'Zip', '1.1.0'
  pod 'GoogleAnalytics', '3.17.0'
  pod 'GoogleIDFASupport'
  pod 'Firebase/Core'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Messaging'
  pod 'lottie-ios'
  pod 'AppsFlyerFramework'
  pod 'MaterialComponents/Buttons'
  pod 'SimplZeroClick'
  pod 'DropDown'
  pod 'SDWebImage'
  pod 'CleverTap-iOS-SDK'
  pod 'IQKeyboardManagerSwift'
  pod 'TransitionButton'
  pod 'Adjust'
  pod 'GoogleSignIn','6.2.4'
  pod 'Branch','1.41.0'
  pod 'AWSIoT'
  pod 'AWSMobileClient'
  pod 'FloatingPanel', '1.7.5'
  pod 'HyperSnapSDK'
  pod 'Netcore-Smartech-iOS-SDK'
  pod 'FTPopOverMenu_Swift','0.2.0'
  pod 'YoutubePlayer-in-WKWebView'
  pod 'BottomPopup'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'

  #source 'https://github.com/CocoaPods/Specs.git'

end

target "ImageNotificationService" do
  pod 'GoogleAnalytics', '3.17.0'
  pod 'GoogleIDFASupport'
end
target "ImageNotificationContent" do
  pod 'GoogleAnalytics', '3.17.0'
  pod 'GoogleIDFASupport'
  pod 'SDWebImage'
end
target "CleverTapNotificationService" do
  pod 'GoogleAnalytics', '3.17.0'
  pod 'GoogleIDFASupport'
  pod 'CTNotificationService'
  pod 'CleverTap-iOS-SDK'
end

target "CleverTapNotificationContent" do
  pod 'GoogleAnalytics', '3.17.0'
  pod 'GoogleIDFASupport'
  pod 'CTNotificationContent'
  pod 'CleverTap-iOS-SDK'
end
target "NetcoreNotificationService" do
  pod 'Netcore-Smartech-iOS-SDK'
  pod 'GoogleAnalytics', '3.17.0'
  pod 'GoogleIDFASupport'
end
target "NetcoreNotificationContent" do
  pod 'Netcore-Smartech-iOS-SDK'
  pod 'GoogleAnalytics', '3.17.0'
  pod 'GoogleIDFASupport'
end
post_install do |installer|
 installer.pods_project.targets.each do |target|
   target.build_configurations.each do |config|
     if config.name == 'Debug'
       config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
       config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
       config.build_settings['SWIFT_COMPILATION_MODE'] = 'singlefile'
     else
       config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
     end
   end
 end
end
