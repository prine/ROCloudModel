#
# Be sure to run `pod lib lint ROCloudModel.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = "ROCloudModel"
s.version          = "0.0.2"
s.summary          = "CloudKit Data Mapper"
s.description      = <<-DESC
Provides an abstract layer above the CloudKit and simplifies the mapping between CKRecord and Swift Data classes.
DESC
s.homepage         = "https://github.com/prine/ROCloudModel"
s.license          = 'MIT'
s.author           = { "Robin Oster" => "robin.oster@rascor.com" }
s.source           = { :git => "https://github.com/prine/ROCloudModel.git", :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/prinedev'

s.platform     = :ios, '8.0'
s.requires_arc = true

s.source_files = 'Source/**/*'
s.resource_bundles = {
'RONetworking' => ['Pod/Assets/*.png']
}

# s.public_header_files = 'Pod/Classes/**/*.h'
s.frameworks = 'UIKit', 'CloudKit'
s.dependency 'ROConcurrency'
end
