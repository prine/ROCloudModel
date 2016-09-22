#
# Be sure to run `pod lib lint ROCloudModel.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#


Pod::Spec.new do |spec|
    spec.name         = 'ROCloudModel'
    spec.version      = '1.1.1'
    spec.license      = { :type => 'MIT' }
    spec.homepage     = 'https://github.com/prine/ROCloudModel'
    spec.authors      = { 'Robin Oster' => 'prine.dev@gmail.com' }
    spec.summary      = 'Provides an abstract layer above the CloudKit and simplifies the mapping between CKRecord and Swift Data classes.'
    spec.source       = { :git => 'https://github.com/prine/ROCloudModel.git', :tag => "1.1.0" }
    spec.source_files = 'Source/**/*'
    spec.framework    = 'SystemConfiguration'
    spec.ios.deployment_target  = '8.4'
    spec.dependency 'ROConcurrency', '~> 2.1'
end
