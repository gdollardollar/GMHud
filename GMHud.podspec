Pod::Spec.new do |s|
  s.name             = 'GMHud'
  s.version          = '1.0.4'
  s.summary          = 'Full screen popups library for iOS'
  s.homepage         = 'https://github.com/gdollardollar/gmhud'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Guillaume Aquilina' => 'guillaume.aquilina@gmail.com' }
  s.source           = { :git => 'https://github.com/gdollardollar/gmhud.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.swift_version = '5'

  s.source_files = 'Source/*.swift'

end
