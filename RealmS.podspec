Pod::Spec.new do |s|
    s.name   = 'RealmS'
    s.version  = '4.0.1'
    s.license  = 'MIT'
    s.summary  = 'RealmS'
    s.homepage = 'https://github.com/tsrnd/realms-ios'
    s.authors  = { 'Dao Nguyen' => 'zendobk' }
    s.source   = { :git => 'https://github.com/tsrnd/realms-ios', :tag => s.version}
    s.requires_arc = true
    s.ios.deployment_target = '8.0'
    s.ios.frameworks = 'Foundation', 'UIKit'
    s.dependency 'RealmSwift', '~> 3.0'
    s.dependency 'ObjectMapper', '~> 3.0'
    s.source_files = 'Sources/*.swift'
end
