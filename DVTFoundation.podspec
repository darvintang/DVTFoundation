Pod::Spec.new do |s|
  s.name             = 'DVTFoundation'
  s.version          = '2.0.3'
  s.summary          = 'DVTFoundation'

  s.description      = <<-DESC
  TODO:
    Foundation的扩展合集，以及一些工具类的封装，例如GCDTimer，封装GCD的计时器
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
