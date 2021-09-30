Pod::Spec.new do |s|
  s.name             = 'DVTFoundation'
  s.version          = '1.0.3'
  s.summary          = 'DVTFoundation'

  s.description      = <<-DESC
  TODO:
    DVTFoundation
  DESC

  s.homepage         = 'https://github.com/darvintang/DVTFoundation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xt-input' => 'input@tcoding.cn' }
  s.source           = { :git => 'https://github.com/darvintang/DVTFoundation.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  s.source_files = 'Sources/**/*.swift'

  s.swift_version = '5'
  s.requires_arc  = true
end
