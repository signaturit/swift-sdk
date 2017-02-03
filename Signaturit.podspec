Pod::Spec.new do |s|
  s.name             = 'Signaturit'
  s.version          = '1.1.0'
  s.license          = { :type => 'MIT' }
  s.summary          = 'Signaturit Swift SDK'

  s.homepage         = 'https://signaturit.com'
  s.author           = { 'Signaturit' => 'api@signaturit.com' }
  s.source           = { :git => 'https://github.com/signaturit/swift-sdk.git', :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = '*'

  s.dependency 'Alamofire', '~> 3.5'
end
