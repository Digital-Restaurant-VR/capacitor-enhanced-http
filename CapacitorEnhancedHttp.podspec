Pod::Spec.new do |s|
  s.name     = 'CapacitorEnhancedHttp'
  s.version  = '1.0.0'
  s.summary  = 'Unsafe HTTPS for antenna provisioning'
  s.homepage = 'https://github.com/Digital-Restaurant-VR/capacitor-enhanced-http'  # fake
  s.license  = 'MIT'
  s.author   = { 'Digital-Restaurant-VR' => 'info@example.com' }
  s.source   = { :git => 'https://github.com/Digital-Restaurant-VR/capacitor-enhanced-http.git', :tag => s.version.to_s }
  s.source_files = 'ios/Plugin/**/*.{swift,h,m}'
  s.requires_arc = true
  s.dependency 'Capacitor'
end