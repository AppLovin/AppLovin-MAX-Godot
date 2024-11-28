# AppLovin MAX Godot Plugin

AppLovin MAX Godot plugin for Android and iOS. We currently only support Godot 4.x.

## Documentation
For information on how to use our plugin in your GDScripts, check out our integration docs [here](https://developers.applovin.com/en/godot/overview/integration).

## Plugin
You may find our plugin on the [Godot Asset Library](https://godotengine.org/asset-library/asset/2141).

We have an example scene `Main.gd` in `/addons/applovin_max/Example/Scenes` that shows an example integration of our APIs.

The source files for the native plugins can be found in the `/Source` folder. The source files for the Godot plugin can be found in `/addons/applovin_max`.
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
4. Once the project has exported, create a Podfile in the same directory as your Xcode project (`.xcodeproj`). We have included an example Podfile in the top level directory of the repo.
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

## Demo Apps
The `/ExampleProject` directory contains the demo app.

<img width="400" alt="image" src="https://github.com/AppLovin/AppLovin-MAX-Godot/assets/23690238/4d03b9e2-5bf8-4dc2-bffd-e87c4868f48f">

## License
MIT
