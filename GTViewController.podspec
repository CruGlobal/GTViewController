Pod::Spec.new do |s|

  s.name         = "GTViewController"
  s.version      = "7.0.0"
  s.summary      = "A View Controller that renders God Tools xml packages"
  s.description  = <<-DESC
                   GTViewController takes a God Tools xml package and renders it for iOS devices.

                   God Tools packages can be downloaded from the God Tools API and can be rendered
                   on Android too. All God Tools code is open source.

                   If you would like to create your own xml packages the documentation is at godtoolsapp.com/docs
                   DESC
  s.homepage     = "http://github.com/CruGlobal/GTViewController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Harro" => "michael.harrison@cru.org" }

  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/CruGlobal/GTViewController.git", :tag => s.version }
  s.source_files = "GTViewController/Classes/**/*.{h,m}", "GTViewController/Headers/*.h"
  s.public_header_files = "GTViewController/Classes/Nav\ Classes/GTViewController.h", "GTViewController/Classes/Custom\ Classes/GTFileLoader.h", "GTViewController/Classes/Nav\ Classes/GTPageMenuViewController.h", "GTViewController/Classes/Custom\ Classes/GTShareViewController.h", "GTViewController/Classes/Custom\ Classes/GTShareInfo.h", "GTViewController/Classes/Parsing\ Classes/GTAboutViewController.h", "GTViewController/Classes/TBXML/TBXML.h", "GTViewController/Classes/Nav\ Classes/GTFollowupViewController.h", "GTViewController/Classes/Custom\ Classes/UISnuffleButton.h"
  s.resources    = "GTViewController/Resources/*", "GTViewController/Classes/**/*.xib"
  s.frameworks   = "QuartzCore", "AVFoundation"
  s.libraries    = "z"
  s.dependency 'SSCWhatsAppActivity', '~> 1.0'

  s.requires_arc = true

end
