import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// key.properties 파일 읽기
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.inoi.ridingmate.dev"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // 공유 keystore를 사용한 signing 설정
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: "androiddebugkey"
            keyPassword = keystoreProperties["keyPassword"] as String? ?: "android"
            storeFile = file(keystoreProperties["storeFile"] as String? ?: "../debug.keystore")
            storePassword = keystoreProperties["storePassword"] as String? ?: "android"
        }
        getByName("debug") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: "androiddebugkey"
            keyPassword = keystoreProperties["keyPassword"] as String? ?: "android"
            storeFile = file(keystoreProperties["storeFile"] as String? ?: "../debug.keystore")
            storePassword = keystoreProperties["storePassword"] as String? ?: "android"
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.inoi.ridingmate.dev"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26  // Health Connect 요구사항 (API 26+)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Health Connect 의존성 - 운동 경로 기능 포함 버전
    implementation("androidx.health.connect:connect-client:1.1.0-alpha12")
    implementation("androidx.activity:activity-compose:1.7.2")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.6.2")
    implementation ("androidx.activity:activity-ktx:1.10.1")
}
