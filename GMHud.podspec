Pod::Spec.new do |s|
  s.name             = 'GMHud'
  s.version          = '0.1.1'
  s.summary          = 'Full screen popups'
  s.homepage         = 'https://github.com/gdollardollar/gmhud'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Guillaume Aquilina' => 'guillaume.aquilina@gmail.com' }
  s.source           = { :git => 'https://github.com/gdollardollar/gmhud.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/*.swift'

end
