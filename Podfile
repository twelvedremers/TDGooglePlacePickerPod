# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'TDGooglePlacePickerPod' do
  # Comment the next line if you don't want to use dynamic frameworks
  #use_frameworks!
  pod 'GoogleMaps', '~> 4.0'
  pod 'GooglePlaces', '~> 4.0'
  pod 'Alamofire', '~> 4.7.3'
  pod 'SwiftyJSON', '~> 5.0.0'
  # Pods for TDGooglePlacePickerPod
  
  # Workaround for Cocoapods issue #7606
  post_install do |installer|
    installer.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
          config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        end
    end
    end

end

