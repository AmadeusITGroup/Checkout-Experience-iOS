#
#  Be sure to run `pod spec lint AmadeusCheckout.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name          = "AmadeusCheckout"
  spec.version       = "1.0.1"
  spec.summary       = "Integration of Amadeus Checkout for iOS."
  spec.homepage      = "https://amadeus.com/en/business-function/payments"
  spec.license       = { :type => "MIT", :file => "LICENSE" }
  spec.author        = "Amadeus"
  spec.platform      = :ios, "10.0"
  spec.source        = { :git => "https://github.com/AmadeusITGroup/Checkout-Experience-iOS.git" , :tag => spec.version.to_s }
  spec.swift_version = "5.0"
  
  spec.subspec "Core" do |core|
      core.source_files  = "AmadeusCheckoutCore/AmadeusCheckout/**/*.{h,swift}"
      core.resources     = [ "AmadeusCheckoutCore/AmadeusCheckout/**/*.{storyboard,json,lproj,xcassets}" ]
  end
  
  spec.subspec "CardIOPlugin" do |cardio|
    cardio.source_files = "AmadeusCheckout-CardIO/AmadeusCheckout-CardIO/**/*.{h,m,swift}"
    cardio.dependency "AmadeusCheckout/Core"
    cardio.dependency "CardIODynamic"
  end
  
end
