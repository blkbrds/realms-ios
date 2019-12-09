source 'https://github.com/CocoaPods/Specs.git'
inhibit_all_warnings!
use_frameworks!
platform :ios, '8.0'

def shared_pods
    pod 'RealmSwift', '~> 3.18.0'
    pod 'ObjectMapper', '~> 3.5.1'
end

target 'RealmS' do
    shared_pods
    pod 'SwiftLint', '~> 0.27.0'
    target 'Tests' do
        inherit! :search_paths
        shared_pods
    end
end

target 'PodTest' do
    pod 'RealmS', :path => './'
end
