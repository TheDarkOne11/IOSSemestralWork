source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
use_frameworks!
workspace 'IOSSemestralWork.xcworkspace'
project 'IOSSemestralWork.xcodeproj'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'IOSSemestralWork' do
    inherit! :search_paths
    
    pod 'AlamofireRSSParser', '~> 2.2.0'
    pod 'RealmSwift', '~> 3.16.2'
    pod 'Toast-Swift', '~> 5.0.0'
    pod 'ACKLocalization', '~> 0.3.3'
    pod 'SwiftGen', '~> 6.1'
    pod 'ReactiveSwift', '~> 6.0.0'
    pod 'ReactiveCocoa', '~> 10.0.0'    # Enables reactive usage of IOS components (UITextField...)
    pod 'Overture', '~> 0.5.0'          # Better functional programming
    pod 'SnapKit', '~> 4.2'             # Easier programmatic creation of UI
end

target 'UnitTests' do
    pod 'RealmSwift', '~> 3.16.2'
    pod 'ReactiveSwift', '~> 6.0.0'
end

target 'FeedTodayAppExtension' do
    pod 'SnapKit', '~> 4.2'
end

def project_path(projectName)
    return "Features/#{projectName}/#{projectName}"
end

target 'Common' do
    project project_path("Common")
    pod 'ReactiveSwift', '~> 6.0.0'
    pod 'ReactiveCocoa', '~> 10.0.0'
end

target 'Data' do
    project project_path("Data")
    pod 'ReactiveSwift', '~> 6.0.0'
    pod 'RealmSwift', '~> 3.16.2'
    pod 'AlamofireRSSParser', '~> 2.2.0'
    target 'DataUnitTests' do
#        project project_path("Data")
        pod 'RealmSwift', '~> 3.16.2'
        pod 'ReactiveSwift', '~> 6.0.0'
        pod 'ReactiveCocoa', '~> 10.0.0'
    end
end
