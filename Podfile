use_frameworks!
inhibit_all_warnings!

source 'podspec git here'
source 'https://github.com/CocoaPods/Specs.git'

project 'HomeSecurityDemoApp.xcodeproj'

platform :'ios', '9.0'
def main_pods
  pod 'HomeSecurityAPI', :git => 'API git here'
  pod 'Alamofire'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Refresher'
  pod 'RxCocoa'
  pod 'RxDataSources'
end

target 'HomeSecurityDemoApp' do
  main_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '2.3'
          config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
        end
    end
end
