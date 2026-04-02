plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.inteligencia_forestal"

    // Recomendado 2025: compileSdk y targetSdk = 34
    compileSdk = 36
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

        // Compatibilidad amplia (Android 7+)
        minSdk = 24

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

dependencies {
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.core:core-ktx:1.13.1")

    // Librerías esenciales para Realidad Aumentada
    implementation("com.google.ar:core:1.43.0")
    implementation("com.google.ar.sceneform.ux:sceneform-ux:1.17.1")
    implementation("com.google.ar.sceneform:core:1.17.1")
}
