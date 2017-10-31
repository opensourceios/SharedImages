source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/crspybits/Specs.git'

use_frameworks!

target 'SharedImages' do
	pod 'Fabric'
	pod 'Crashlytics'

# 	pod 'SyncServer', '~> 4.1'
# 	pod 'SyncServer/Facebook', '~> 4.1'
	
	pod 'SyncServer', :path => '../SyncServer-iOSClient'
	pod 'SyncServer/Facebook', :path => '../SyncServer-iOSClient'
	
	pod 'SyncServer-Shared', :path => '../SyncServer-Shared'
# 	
# 	pod 'SMCoreLib', :path => '../Common/SMCoreLib/'

	# Using my fork because of changes I made
	pod 'ODRefreshControl', :git => 'https://github.com/crspybits/ODRefreshControl.git'
	
    pod 'GoogleSignIn', '~> 4.0'
    
    pod 'SDCAlertView', '~> 7.1'
    
    pod 'LottiesBottom', '~> 0.2'
    # pod 'LottiesBottom', :path => '../LottiesBottom/'
    
	target 'SharedImagesTests' do
    	inherit! :search_paths
    			
# 		pod 'SyncServer', '~> 4.1'
# 		pod 'SyncServer/Facebook', '~> 4.1'

# 		pod 'SMCoreLib', :path => '../Common/SMCoreLib/'
		pod 'SyncServer', :path => '../SyncServer-iOSClient'
		pod 'SyncServer/Facebook', :path => '../SyncServer-iOSClient'
		pod 'SyncServer-Shared', :path => '../SyncServer-Shared'

    	pod 'GoogleSignIn', '~> 4.0'
  	end
  	
  	# 9/14/17; Cocoapods isn't quite ready for Xcode9. This is a workaround:
	# See also https://github.com/CocoaPods/CocoaPods/issues/6791
	
	post_install do |installer|
	
		myTargets = ['Gloss', 'SDCAlertView', 'SyncServer-Shared', 'FacebookCore', 'SyncServer', 'SMCoreLib']
		
		installer.pods_project.targets.each do |target|
			if myTargets.include? target.name
				target.build_configurations.each do |config|
					config.build_settings['SWIFT_VERSION'] = '3.2'
				end
			end
		end
	end
end

