plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // IMPORTANT: namespace, applicationId and the Kotlin package of MainActivity
    // must all stay identical. The manifest entry `.MainActivity` resolves against
    // the namespace; if the Kotlin class lives in a different package the app
    // crashes instantly on launch with ClassNotFoundException on every Android
    // version. (This exact mismatch caused the "app auto-crash" bug.)
    namespace = "com.dailyhisab.app"
    compileSdk = flutter.compileSdkVersion
    // No ndkVersion declared: no plugin in this project compiles native code,
    // so the build does not need an NDK download.

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.dailyhisab.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
