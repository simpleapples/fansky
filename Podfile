platform :ios, '10.0'
use_frameworks!

target 'fansky' do

pod 'TDOAuth'
pod 'SDWebImage', '~>3.7'
pod 'ARSegmentPager', :git => 'https://github.com/AugustRush/ARSegmentPager.git'
pod 'JTSImageViewController'
pod 'JSQMessagesViewController'
pod 'WSProgressHUD'
pod 'MWPhotoBrowser'
pod 'VTAcknowledgementsViewController'
pod 'DTCoreText'
pod 'MIBlurPopup'
pod 'LTHPasscodeViewController'
pod 'LGRefreshView'
pod 'Fabric'
pod 'Crashlytics'
pod 'STPopup'

end

target 'ShareExtension' do

pod 'TDOAuth'

end

target 'fanskyTests' do

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
