pluginManagement {
    repositories {
        google()          // Required for Android plugins
        mavenCentral()    // Additional repository
        gradlePluginPortal() // Optional but useful for other plugins
    }
    plugins {
        id("com.android.library") version "7.3.0"
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        flatDir {
            dirs("libs")
        }
    }
}

rootProject.name = "AppLovin-MAX-Godot"
