# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'swift3_google_maps' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'GoogleMaps', '= 2.1.0'
  pod 'WhereAmI', '~> 4.0'

  # Pods for swift3_google_maps

  target 'swift3_google_mapsTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'swift3_google_mapsUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                        config.build_settings['SWIFT_VERSION'] = '3.0'
                                end
                                    end
                                    end
