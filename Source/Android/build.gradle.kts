plugins {
    id("com.android.library")
}

private val versionMajor = 1
private val versionMinor = 0
private val versionPatch = 2

var libraryVersionName by extra("${versionMajor}.${versionMinor}.${versionPatch}")
var libraryVersionCode by extra((versionMajor * 10000) + (versionMinor * 100) + versionPatch)
var libraryArtifactId by extra("applovin-max-godot-plugin")
var libraryArtifactName by extra("${libraryArtifactId}-${libraryVersionName}.aar")

var libraryVersions = rootProject.extra["versions"] as Map<*, *>

//buildscript {
//    dependencies {
//        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10")
//    }
//}

android {
    compileSdkVersion(libraryVersions["compileSdk"] as Int)

    defaultConfig {
        minSdkVersion(libraryVersions["minSdk"] as Int)
        targetSdkVersion(libraryVersions["targetSdk"] as Int)

        consumerProguardFiles("proguard-rules.pro")

        buildConfigField("String", "VERSION_NAME", "\"${libraryVersionName}\"")
        buildConfigField("int", "VERSION_CODE", libraryVersionCode.toString())
    }

    flavorDimensions("default")
    productFlavors {
        // Flavor when building Unity Plugin as a standalone product
        create("standalone") {
            buildConfigField("boolean", "IS_TEST_APP", "false")
        }
        // Flavor from the test app
        create("app") {
            buildConfigField("boolean", "IS_TEST_APP", "true")
        }
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
        }
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {

    // AppLovin Workspace SDK
    if (file("../../../SDK-Android/Android-SDK/build.gradle.kts").exists()) {
        compileOnly(project(":Android-SDK"))
    } else {
        compileOnly("com.applovin:applovin-sdk:+@aar")
    }

    // Godot Engine
    compileOnly("org.godotengine.godot:godot-lib:+@aar")
}

repositories {
    mavenCentral()

    flatDir {
        dirs("libs")
    }
}