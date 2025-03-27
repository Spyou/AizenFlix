plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // ✅ Better Kotlin plugin ID
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.spyou.anilist_test"
    compileSdk = 34
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.spyou.anilist_test"
        minSdk = 21 // ✅ Safe minimum for most plugins
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // ✅ If needed for large method count
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // replace with your own signing config
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.10.1") // ✅ Prevent lStar error
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.multidex:multidex:2.0.1") // ✅ For large apps
}
