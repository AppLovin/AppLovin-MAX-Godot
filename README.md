# AppLovin MAX Godot Plugin

AppLovin MAX Godot plugin for Android and iOS. We currently only support Godot 4.x.

## Documentation
You may find our plugin on the [Godot Asset Library](https://godotengine.org/asset-library/asset/2141).

We have an example scene `Main.gd` in `/addons/applovin_max/Example/Scenes` that shows an example integration of our APIs.
<img width="400" alt="image" src="https://github.com/AppLovin/AppLovin-MAX-Godot/assets/23690238/4d03b9e2-5bf8-4dc2-bffd-e87c4868f48f">

For information on how to use our plugin in your GDScripts, check out our integration docs [here](https://developers.applovin.com/en/godot/overview/integration).

## Plugin Integration Instructions
This section will provide the instructions on how to add the plugin to your Godot project and how to set up your Xcode and Android Studio projects.

### Adding the Plugin
- Download the assets from the [Godot Asset Library](https://godotengine.org/asset-library/asset/2141) or directly from this repo with the `/addons`, `/ios`, `/android` directories.
- In your Godot project, your `//res:` directory should look like this:

  <img width="300" alt="image" src="https://github.com/AppLovin/AppLovin-MAX-Godot/assets/23690238/27751e15-32b4-4e24-906c-c24465b4c26d">

### Exporting/Building to iOS/Android

#### iOS
1. In the Godot editor, open the `Export` window from the `Project` menu. When the `Export` window opens, click `Add..` and select `iOS`.
  - The `App Store Team ID` and `(Bundle) Identifier` options in the `Application` category are required.
2. In the `Plugins` category, the `App Lovin Max` checkbox must be enabled.
   
  <img width="400" alt="image" src="https://github.com/AppLovin/AppLovin-MAX-Godot/assets/23690238/d8320199-6288-472d-93db-c81912bbddc3">
  
3. Click on `Export Project...`.

  **Note**: You will see the export "fail" and see the error `[Xcode Build]: Xcode project build failed, see editor log for details`.
  
  <img width="400" alt="image" src="https://github.com/AppLovin/AppLovin-MAX-Godot/assets/23690238/c331552e-7fa5-4e4b-ba3f-006de2bcd694">
  
  - This is an expected error, as the AppLovinSDK.framework is not included in the plugin by default. The reasoning behind this is to leverage Cocoapods to manage the iOS dependencies such as other ad network SDKs and our mediation adapters for them.
  - We have future plans to help streamline this process.
4. Once the project has exported, create a Podfile in the same directory as your Xcode project (`.xcodeproj`). We have included an example Podfile in the `Example-Xcode-Project` directory of the repo. Note: do not use the Podfile at the top-level directory as it is setup to build and use the plugin source files.
  - To add other networks and their dependencies, please visit [Preparing Mediated Networks](https://developers.applovin.com/en/godot/preparing-mediated-networks#ios). This tool will automatically generate the Podfile code.
  - Note: Your Xcode project will not run by default as noted before until you run the next step.
5. Finally, to install our AppLovinSDK and your dependencies, run the following on your command line tool:
  ```
  pod install --repo-update
  ```

##### Other iOS Considerations
- `Tip:` *Removing the need to export repeatedly*
  
Check out the `Active development considerations` section in Godot's [Exporting for iOS](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html#doc-exporting-for-ios) doc.

This will allow you to make changes to your game code without having to export to Xcode again. You can simply make changes in Godot and run your build in your Xcode project immediately after.

#### Android
1. Requirement: please read Godot's [Exporting for Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) on how to setup your Godot project for Android.
2. In the Godot editor, click on `Install Android Build Template...` from the Project menu. Click `Install`.
3. In the Godot editor, open the `Export` window from the `Project` menu. When the `Export` window opens, click `Add..` and select `Android`.
4. In the `Plugins` category, `App Lovin Max` checkbox must be enabled.
   
  <img width="400" alt="image" src="https://github.com/AppLovin/AppLovin-MAX-Godot/assets/23690238/d8320199-6288-472d-93db-c81912bbddc3">
  
5. Click on `Export Project...`
6. Open the Android Studio project. By default, it will be in `<GODOT_PROJECT>/android/build` folder.
  - Note: Your Android Studio project will not run properly by default.
    1. Godot can fail to export our plugin AAR to the Android Studio project. We will be using Gradle for dependency management. See Step 7 and onwards.
    2. As mentioned before, Godot can also fail to export your package name properly. See [Other considerations](#other-android-considerations).
7. Copy the `AppLovin-MAX-Godot-Plugin.aar` in `<GODOT_PROJECT>/android/plugins/AppLovin-MAX-Godot-Plugin` to the `libs` directory in `<GODOT_PROJECT>/android/build/libs`.
8. In the `build.gradle`, add the following line in the `dependencies` code block:
```
implementation 'com.applovin:applovin-sdk:+'
```
  - To add other networks and their dependencies, please visit [Preparing Mediated Networks](https://developers.applovin.com/en/godot/preparing-mediated-networks#android). This tool will automatically generate the gradle code.
9. In the `AndroidManifest.xml`, in the `.GodotApp` activity entry, change the `android:launchMode` attribute value from `singleInstance` to `singleTask`.

## Repo Structure
This repo contains the following:

### AppLovinMAX Godot Plugin
The root-level of this repo is structured to provide the official plugin and assets to Godot Asset Library:
- The Godot plugin source code is located in `addons/applovin_max`.
- The official Android Godot plugin `aar` library and `gdap` configuration file is located in `android/plugins/AppLovin-MAX-Godot-Plugin`
- The official iOS Godot plugin `.a` library and `.gdip` configuration file is located in `ios/plugins/AppLovin-MAX-Godot-Plugin`

### AppLovinMAX Godot Development and Example Project
The root-level of this repo contains a Godot Example project used to develop and export the Example project (with the AppLovin-MAX-Godot plugin) to Xcode and Android Studio.
Files/Folders:
- **project.godot**, Open the project in the Godot IDE
- **addons/applovin_max/**, contains the official AppLovin-MAX-Godot plugin gdscripts.
- **addons/applovin_max/Example**, contains the Example project's main scene (`main.tscn`) and source code (`main.gd`)
- **export_presets.cfg**, Export Configuration file. Used for exporting to Xcode/Android Studio.
  - For Xcode, the export path is already defined to 'Example-Xcode-Project/`.
  - For Android, you must first install the Android Studio Build Template under the Project options which will create the Android Studio project in `android/build`. Godot does not directly export to Android Studio; the export action essentially updates the build template project.
- **android/build/**, as noted above, this is the Android Studio project for the Godot Example project. You must first install the Android Studio Build Template under the Project options to generate the project.
- **Example-Xcode-Project/**, export in the Godot IDE to generate the Xcode Project for the Godot Example project.

### iOS Plugin
The root-level and `Source/iOS` of this repo contains the Xcode workspace needed to build and develop the iOS `AppLovin-MAX-Godot-Plugin`.
- **AppLovin-MAX-Godot.xcworkspace**, workspace contains both the `AppLovin-MAX-Godot-Plugin` xcodeproj and the `Example` xcodeproj (if available/exported).
- **Podfile**, run `pod install` to add the `AppLovinSDK` dependency to workspace. This is where additional ad networks/adapters can be added to the `Example` xcodeproj. Note: there are two Podfiles in the repo; one is the top-level and the other is in the `Example-Xcode-Project` directory. The former is used to build the iOS plugin and Example project; the latter is used to build Example project as a standalone project.
- **Source/iOS/AppLovin-MAX-Godot-Plugin**, contains the iOS plugin source code.
- **Source/iOS/build**, used by the `godot_plugin.py` script to build the plugin `.a` library and its intermediaries.
- **Example-Xcode-Project**, by default, this will use the official iOS plugin, but the dependency can be updated to use the local `AppLovin-MAX-Godot-Plugin.xcodeproj` version. 

### Android Plugin
The `Source/Android` of this repo contains Android Studio project needed to build and develop the Android `AppLovin-MAX-Godot-Plugin`.
- **Source/Android**, the Android Studio project contains the plugins source files and its `build.gradle` references the necessary dependencies on the `godot-lib.aar` and AppLovinSDK `aar`. Note: as of Godot 4.3, the latest Java supported is Java 17.

## godot_plugin.py
This scripts standardizes the build and development process of the iOS and Android plugins. Please use Python 3.x to run the script.

### Commands
#### `python3 godot_plugin.py prepare_plugin_environment <GODOT_VERSION>`
Prepares the working space for iOS and Android development. Steps 2/4/5 prepares iOS; Step 3 prepares Android.

This command does the following:
1. Cleans the working space and removes artifacts generated by previous builds or downloads.
2. Downloads the `godot engine` source code using the given `<GODOT_VERSION>`.
3. Downloads the official Godot Android library using the given `<GODOT_VERSION>`.
4. Generates the godot engine's iOS headers so the plugin may reference them.
5. Runs `pod install` for AppLovin-MAX-Godot.xcworkspace and installs the `AppLovinSDK` dependency.

#### `python3 godot_plugin.py build_ios`
Builds the iOS plugin to `ios/plugins/AppLovin-MAX-Godot-Plugin`.

#### `python3 godot_plugin.py build_android`
Builds the Android plugin to `android/plugins/AppLovin-MAX-Godot-Plugin`

## License
MIT
