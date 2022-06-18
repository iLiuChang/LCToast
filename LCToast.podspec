Pod::Spec.new do |s|
  s.name         = "LCToast"
  s.version      = "1.2.0"
  s.summary      = "Add toast to UIView."
  s.homepage     = "https://github.com/iLiuChang/LCToast"
  s.license      = "MIT"
  s.author       = "LiuChang"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/iLiuChang/LCToast.git", :tag => s.version }
  s.requires_arc = true
  s.source_files = "LCToast/*.{h,m}"
  s.framework    = "UIKit"
  s.requires_arc = true
end