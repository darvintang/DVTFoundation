Pod::Spec.new do |s|
  s.name             = 'DVTFoundation'
  s.version          = '2.0.0'
  s.summary          = 'DVTFoundation'

  s.description      = <<-DESC
  TODO:
    DVTFoundation
  DESC

  s.homepage         = 'https://github.com/darvintang/DVTFoundation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'darvin' => 'darvin@tcoding.cn' }
  s.source           = { :git => 'https://github.com/darvintang/DVTFoundation.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'

  s.source_files = 'Sources/**/*.swift'
  s.swift_version = '5'
  s.requires_arc  = true
end
