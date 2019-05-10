Pod::Spec.new do |s|

  s.name             = "LMGaugeView"
  s.version          = "1.1.0"
  s.summary          = "LMGaugeView is a simple and customizable gauge control for iOS."
  s.homepage         = "https://github.com/june20com/LMGaugeView"
  s.license          = 'MIT'
  s.authors           = { "LMinh" => "lminhtm@gmail.com", "Todd Reed" => "todd@convergeretail.com" }
  s.source           = { :git => "git@github.com:june20com/LMGaugeView.git", :tag => s.version.to_s }

  s.platform     = :ios, '11.0'
  s.requires_arc = true

  s.source_files = 'LMGaugeView/**/*.{h,m}'

end
