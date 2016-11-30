Pod::Spec.new do |s|
    s.name   = 'RealmS'
    s.version  = '2.1.0'
    s.license  = 'MIT'
    s.summary  = 'RealmS'
    s.homepage = 'https://github.com/zendobk/RealmS'
    s.authors  = { 'Dao Nguyen' => 'zendobk' }
    s.source   = { :git => 'https://github.com/zendobk/RealmS.git', :tag => s.version}
    s.requires_arc = true
    s.ios.deployment_target = '8.0'
    s.ios.frameworks = 'Foundation', 'UIKit'
    s.dependency 'RealmSwift', '~> 2.1.0'
    s.dependency 'ObjectMapper', '~> 2.2.0'
    s.source_files = 'Sources/*.swift'
end
