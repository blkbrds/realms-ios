source 'https://github.com/CocoaPods/Specs.git'
inhibit_all_warnings!
use_frameworks!
platform :ios, '8.0'

def shared_pods
    pod 'RealmSwift', '~> 1.0'
    pod 'ObjectMapper', '~> 1.2.0'
end

target 'RealmS' do
    shared_pods
    target 'Tests' do
        inherit! :search_paths
        shared_pods
    end
end
