#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint review_etiquette.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'review_etiquette'
  # Flutter resolves this pod by path, so the version is never used for resolution.
  # Keeping it pinned avoids a second place that every release would have to bump.
  s.version          = '0.0.1'
  s.summary          = 'Asks for an in-app review at the right moment.'
  s.description      = <<-DESC
Asks for an in-app review after your app delivered value instead of on launch,
following the review request rules Apple and Google describe.
                       DESC
  s.homepage         = 'https://github.com/BoundfoxStudios/review_etiquette'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = 'BoundfoxStudios'
  s.source           = { :path => '.' }
  s.source_files = 'review_etiquette/Sources/review_etiquette/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '16.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '6.0'

  s.resource_bundles = {'review_etiquette_privacy' => ['review_etiquette/Sources/review_etiquette/PrivacyInfo.xcprivacy']}
end
