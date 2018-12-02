Pod::Spec.new do |s|
  s.name             = "MotionJpegController"
  s.version          = "1.0"
  s.summary          = "Controller to allow injecting a motion jpeg stream in a view"
  s.homepage         = "https://github.com/lacyrhoades/MotionJpegController"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { "Lacy Rhoades" => "lacy@colordeaf.net" }
  s.source           = { git: "https://github.com/lacyrhoades/MotionJpegController.git" }
  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.ios.source_files = 'Source/**/*.swift'
  s.exclude_files = 'Source/**/*Test.swift'
  end
