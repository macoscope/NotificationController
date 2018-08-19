Pod::Spec.new do |s|
  s.name             = "NotificationController"
  s.version          = "1.0"
  s.summary          = "A safer and easier way to use NSNotificationCenter with blocks."
  s.homepage         = "https://github.com/macoscope/NotificationController"
  s.license          = 'MIT'
  s.author           = { "Arkadiusz Holko" => "fastred@fastred.org" }
  s.social_media_url = "https://twitter.com/arekholko"
  s.source           = { :git => "https://github.com/macoscope/NotificationController.git", :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '4.0'

  s.requires_arc = true
  s.source_files = 'MCSNotificationController/*.{h,m}', 'MCSNotificationController/**/*.{h,m}'
  s.public_header_files = 'MCSNotificationController/*.h'
end
