plugins {
    id("com.android.library")
}

private val versionMajor = 1
private val versionMinor = 1
private val versionPatch = 2

var libraryVersionName by extra("${versionMajor}.${versionMinor}.${versionPatch}")
var libraryVersionCode by extra((versionMajor * 10000) + (versionMinor * 100) + versionPatch)
var libraryArtifactId by extra("applovin-max-godot-plugin")
var libraryArtifactName by extra("${libraryArtifactId}-${libraryVersionName}.aar")

android {
    namespace = "com.applovin.godot"
    compileSdk = 33

    defaultConfig {
        minSdk = 19

        consumerProguardFiles("proguard-rules.pro")

        buildConfigField("String", "VERSION_NAME", "\"${libraryVersionName}\"")
        buildConfigField("int", "VERSION_CODE", libraryVersionCode.toString())
    }

    flavorDimensions.add("default")
    productFlavors {
        create("app") {
            dimension = "default"
        }
        create("standalone") {
            dimension = "default"
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
    compileOnly("com.applovin:applovin-sdk:+@aar")

    // Godot Engine
    compileOnly("org.godotengine.godot:godot-lib:+@aar")
}
