# AppLovin MAX Godot Plugin

AppLovin MAX Godot plugin for Android and iOS.

## Plugin
The `AppLovinMAXGodotPlugin-x.x.x` directory contains the plugin assets/files.

## Plugin Integration Instructions
This section will provide the instructions on how to add the plugin to your Godot project and how to set up your Xcode and Android Studio projects.

### Adding the Plugin
- Download the assets in the `AppLovinMAXGodotPlugin-x.x.x` directory.
- In your Godot project, add the `addons/`, `android`, `ios` folders in the `AppLovinMAXGodotPlugin-x.x.x` directory to your Godot project's `//res:` directory
  
  <img width="300" alt="image" src="https://github.com/AppLovin/AppLovin-MAX-Godot/assets/23690238/1ef41a94-73cc-411b-aa72-a2a01cbebe6d">

### Exporting/Building to iOS/Android

#### iOS
Reference: Godot's [Exporting for iOS](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html#doc-exporting-for-ios) doc for exporting to an Xcode project.

1. In the Godot editor, open the `Export` window from the `Project` menu. When the `Export` window opens, click `Add..` and select `iOS`.
  - The `App Store Team ID` and `(Bundle) Identifier` options in the `Application` category are required.
2. In the `Plugins` category, `App Lovin Max` checkbox must be enabled.
   
  <img width="400" alt="image" src="https://github.com/AppLovin/AppLovin-MAX-Godot/assets/23690238/d8320199-6288-472d-93db-c81912bbddc3">
  
3. Click on `Export Project...`.
  **Note**: You will see the export "fail" and see the error `[Xcode Build]: Xcode project build failed, see editor log for details`.
  
  <img width="400" alt="image" src="https://github.com/AppLovin/AppLovin-MAX-Godot/assets/23690238/c331552e-7fa5-4e4b-ba3f-006de2bcd694">
  
  - This is an expected error, as the AppLovinSDK.framework is not included in the plugin by default. The reasoning behind this is to leverage Cocoapods to manage the iOS dependencies such as other ad network SDKs and our mediation adapters for them.
  - We have future plans to help streamline this process.
4. Once the project has exported, create a Podfile in the same directory as your Xcode project (`.xcodeproj`). We have included an example Podfile in the top level directory of the repo.
  - To add other networks and their dependencies, please visit [Preparing Mediated Networks](https://dash.applovin.com/documentation/mediation/godot/mediation-adapters/ios). This tool will automatically generate the Podfile code.
  - Note: Your Xcode project will not run by default as noted before until you run the next step.
5. Finally, to install our AppLovinSDK and your dependencies, run the following on your command line tool:
  ```
  pod install --repo-update
  ```

##### Other considerations
- *Removing the need to export repeatedly*
  
Check out the `Active development considerations` section in Godot's [Exporting for iOS](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html#doc-exporting-for-ios) doc.

This will allow you to make changes to your game code without having to export to Xcode again. You can simply make changes in Godot and run your build in your Xcode project immediately after.

#### Android
Reference: Godot's [Exporting for Android]([https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html#doc-exporting-for-ios](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)) doc for exporting to an Android Studio project.

1. Requirement: please read the above reference on how to setup your Godot project for Android.
2. In the Godot editor, click on `Install Android Build Template...` from the Project menu. Click `Install`.
3. In the Godot editor, open the `Export` window from the `Project` menu. When the `Export` window opens, click `Add..` and select `Android`.
4. In the `Plugins` category, `App Lovin Max` checkbox must be enabled.
   
  <img width="400" alt="image" src="https://github.com/AppLovin/AppLovin-MAX-Godot/assets/23690238/d8320199-6288-472d-93db-c81912bbddc3">
  
5. Click on `Export Project...`
  - Note: if you provided a `Unique Name` under the `Package` category, it does not seem to apply the package name to the Android Studio project. We will need to replace it manually yourself in the Android Studio project.
6. Open the Android Studio project. By default, it will be in `<GODOT_PROJECT>/android/build` folder.
  - Note: Your Android Studio project will not run properly by default.
    1. Godot can fail to export our plugin AAR to the Android Studio project. We will be using Gradle for dependency management. See Step 7 and onwards.
    2. Godot can also fail to export your package name properly. See `Other considerations`.
7. Copy the `AppLovin-MAX-Godot-Plugin.aar` in `<GODOT_PROJECT>/android/plugins/AppLovin-MAX-Godot-Plugin` to the `libs` directory in <GODOT_PROJECT>/android/build/libs`.
8. In the `build.gradle`, add the following line in the `dependencies` code block:
```
implementation 'com.applovin:applovin-sdk:+'
```
  - To add other networks and their dependencies, please visit [Preparing Mediated Networks](https://dash.applovin.com/documentation/mediation/godot/mediation-adapters/android). This tool will automatically generate the gradle code.

##### Other considerations
- *`com.godot.game` package name*
  - Click on `Replace in Files...` under `Find` menu option (cmd+shift+R if you are on macOS).
  - Search for `com.godot.game` and replace it with your desire package name.
  - In your `src` directory, rename the subdirectories from `src`/`com`/`godot`/`game` to your desired package name.

## Documentation
For information on how to use our plugin in your GDScripts, check out our integration docs [here](https://dash.applovin.com/documentation/mediation/godot/getting-started/integration).

## Demo Apps
The `/ExampleProject` directory contains the demo app.

<img width="832" alt="image" src="https://github.com/AppLovin/AppLovin-MAX-Godot/assets/5104410/f7fbbef0-6631-46ab-8661-b28d9b3c3d4e">

## License
MIT
