source 'https://cdn.cocoapods.org/'

# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
use_frameworks!
workspace 'IOSSemestralWork.xcworkspace'
project 'IOSSemestralWork.xcodeproj'

# ignore all warnings from all pods
inhibit_all_warnings!

CCPod = Struct.new(:name, :version, :git, :branch)
alamofire = CCPod.new('Alamofire', '~> 4.9.1')
alamofireRSSParser = CCPod.new('AlamofireRSSParser', '~> 2.2.0')
realmSwift = CCPod.new('RealmSwift', '~> 3.16.2')
toastSwift = CCPod.new('Toast-Swift', '~> 5.0.0')
ackLocalization = CCPod.new('ACKLocalization', '~> 0.3.3')
swiftgen = CCPod.new('SwiftGen', '~> 6.1')
reactiveSwift = CCPod.new('ReactiveSwift', '~> 6.2.0')
reactiveCocoa =  CCPod.new('ReactiveCocoa', '~> 10.2.0')    # Enables reactive usage of IOS components (UITextField...)
overture = CCPod.new('Overture', '~> 0.5.0' )         # Better functional programming
snapkit = CCPod.new('SnapKit', '~> 5.0.1')    # Easier programmatic creation of UI

target 'IOSSemestralWork' do
    inherit! :search_paths
    
    pod alamofire.name, alamofire.version
    pod alamofireRSSParser.name, alamofireRSSParser.version
    pod realmSwift.name, realmSwift.version
    pod toastSwift.name, toastSwift.version
    pod ackLocalization.name, ackLocalization.version
    pod swiftgen.name, swiftgen.version
    pod reactiveSwift.name, reactiveSwift.version
    pod reactiveCocoa.name, reactiveCocoa.version
    pod overture.name, overture.version
    pod snapkit.name, snapkit.version
end

target 'UnitTests' do
    pod realmSwift.name, realmSwift.version
    pod reactiveSwift.name, reactiveSwift.version
end

target 'FeedTodayAppExtension' do
    pod snapkit.name, snapkit.version
    pod alamofire.name, alamofire.version
    pod alamofireRSSParser.name, alamofireRSSParser.version
    pod realmSwift.name, realmSwift.version
    pod reactiveSwift.name, reactiveSwift.version
    pod reactiveCocoa.name, reactiveCocoa.version
end

def project_path(projectName)
    return "Features/#{projectName}/#{projectName}"
end

target 'Common' do
    project project_path("Common")
    pod reactiveSwift.name, reactiveSwift.version
    pod reactiveCocoa.name, reactiveCocoa.version
end

target 'Data' do
    project project_path("Data")
    pod reactiveSwift.name, reactiveSwift.version
    pod realmSwift.name, realmSwift.version
    pod alamofire.name, alamofire.version
    pod alamofireRSSParser.name, alamofireRSSParser.version
    target 'DataUnitTests' do
#        project project_path("Data")
        pod realmSwift.name, realmSwift.version
        pod reactiveSwift.name, reactiveSwift.version
        pod reactiveCocoa.name, reactiveCocoa.version
    end
end
