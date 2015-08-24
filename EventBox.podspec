Pod::Spec.new do |s|
  s.name             = "EventBox"
  s.version          = "1.0.0"
  s.summary          = "Provides an interface for use the `addObserverForName` safely and easily."
  s.description      = <<-DESC
                         Provides an interface for use the `addObserverForName` safely and easily.
                         - Comprehensive Unit Test Coverage
                         - Carthage support
                         - Thread-safe
                       DESC
  s.homepage         = "https://github.com/s-aska/EventBox"
  s.license          = "MIT"
  s.author           = { "aska" => "s.aska.org@gmail.com" }
  s.social_media_url = "https://twitter.com/su_aska"
  s.source           = { :git => "https://github.com/s-aska/EventBox.git", :tag => "#{s.version}" }

  s.platform = :ios
  s.ios.deployment_target = "8.0"
  s.requires_arc = true

  s.source_files = 'EventBox/*.swift'
end
