source 'https://cdn.cocoapods.org/'

use_frameworks!
platform :ios, '12.0'

workspace 'AppLovin-MAX-Godot'

plugin_path = Pathname.new('Source/iOS/AppLovin-MAX-Godot-Plugin.xcodeproj')
if plugin_path.exist?()
    target 'AppLovinMAXGodotPlugin' do
        project plugin_path

        pod 'AppLovinSDK'
    end
end

example_path = Pathname.new('Example-Xcode-Project/Example.xcodeproj')
if example_path.exist?()
    target 'Example' do
        project example_path

        pod 'AppLovinSDK'
    end
end
