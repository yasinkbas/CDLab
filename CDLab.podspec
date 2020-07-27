Pod::Spec.new do |s|
  s.name             = 'CDLab'
  s.version          = '0.1.0'
  s.summary          = 'A petty core data layer.'
  s.homepage         = 'https://github.com/yasinkbas/CDLab'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yasinkbas' => 'yasin.kbas12@gmail.com' }
  s.source           = { :git => 'https://github.com/yasinkbas/CDLab.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'CDLab/Classes/**/*'
   s.frameworks = 'CoreData'
  s.dependency 'QueryKit', '~> 0.14.1'
end
