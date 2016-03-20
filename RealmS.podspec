Pod::Spec.new do |s|
  s.name   = 'RealmS'
  s.version  = '1.3.1'
  s.license  = 'MIT'
  s.summary  = 'RealmS'
  s.homepage = 'https://github.com/zendobk/RealmS'
  s.authors  = { 'Dao Nguyen' => 'zendobk' }
  s.source   = { :git => 'https://github.com/zendobk/RealmS.git', :tag => s.version}
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
	s.ios.frameworks = 'Foundation', 'UIKit'
  s.dependency 'RealmSwift', '~> 0.98'
  s.dependency 'ObjectMapper', '~> 1.1'
  s.source_files = 'RealmS/*.swift'
end