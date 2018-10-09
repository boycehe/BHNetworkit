#
# Be sure to run `pod lib lint BHNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BHNetworkit'
  s.version          = '0.1.0'
  s.summary          = 'BHNetworkit is a new style networkingkit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
   easy
                       DESC

  s.homepage         = 'https://git.elenet.me/BH-iOS/BHNetworkit'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'boycehe.com' => 'boycehe.com' }
  s.source           = { :git => 'git@git.elenet.me:BH-iOS/BHNetworkit.git', :tag => s.version.to_s }
  

  s.ios.deployment_target = '8.0'

  #s.source_files = 'BHNetworkit/Classes/**/*'

  s.dependency 'AFNetworking', '~> 3.1.0'
  s.dependency 'ReactiveObjC'
  s.dependency 'YYModel'

  s.subspec 'RAC' do |ss|
    ss.source_files = 'BHNetworkit/Classes/RAC/*.{h,m}'
    ss.public_header_files = 'BHNetworkit/Classes/RAC/*.h'
  end
  s.subspec 'Networking' do |ss|
    ss.dependency 'BHNetworkit/RAC'
    ss.source_files = 'BHNetworkit/Classes/Networking/*.{h,m}'
    ss.public_header_files = 'BHNetworkit/Classes/Networking/*.h'
  end


end
