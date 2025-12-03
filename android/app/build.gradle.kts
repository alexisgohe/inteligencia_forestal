plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.inteligencia_forestal"

    // Recomendado 2025: compileSdk y targetSdk = 34
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    // Java 17 – requerido por AGP moderno y más estable para Flutter
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.inteligencia_forestal"

        // Compatibilidad amplia (Android 6+)
        minSdk = flutter.minSdkVersion

        // Meta Play Store 2024–2025
        targetSdk = 34

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
