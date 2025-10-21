plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firebase SHA-1과 일치하는 전역 debug keystore 사용

android {
    namespace = "com.inoi.urbanbreeze"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Firebase SHA-1과 일치하는 전역 debug keystore 사용
    signingConfigs {
        // 프로덕션용 릴리즈 키스토어
        create("release") {
            keyAlias = "upload"
            keyPassword = "urbanbreeze2025"
            storeFile = file(System.getProperty("user.home") + "/upload-keystore.jks")
            storePassword = "urbanbreeze2025"
        }
        // 개발용 디버그 키스토어
        getByName("debug") {
            keyAlias = "androiddebugkey"
            keyPassword = "android"
            storeFile = file(System.getProperty("user.home") + "/.android/debug.keystore")
            storePassword = "android"
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.inoi.urbanbreeze"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 28  // Terra Flutter Bridge 요구사항 (API 28+)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["googleClientId"] = "723259332020-r5u1laq4umq0v0n489d2b4k81vj0ugo3.apps.googleusercontent.com"
            manifestPlaceholders["kakaoScheme"] = "kakao92a46589034ed2af1f0a6d12578996cd"
            manifestPlaceholders["appLabel"] = "Urban Breeze Dev"
            // Dev는 항상 debug 키스토어 사용 (개발용)
            signingConfig = signingConfigs.getByName("debug")
        }
        create("prod") {
            dimension = "environment"
            manifestPlaceholders["googleClientId"] = "723259332020-2ms0qnupo6ntk7um52d6f8ct4s0fvk3h.apps.googleusercontent.com"
            manifestPlaceholders["kakaoScheme"] = "kakaoea26fa3b97208688a71b31b17df4813c"
            manifestPlaceholders["appLabel"] = "Urban Breeze"
            // Prod는 항상 release 키스토어 사용 (Firebase SHA-1 일치)
            signingConfig = signingConfigs.getByName("release")
        }
    }

    buildTypes {
        getByName("debug") {
            // flavor별 키스토어 설정 사용
            signingConfig = null // flavor별 signingConfig 사용
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("release") {
            // flavor별 키스토어 설정 사용
            signingConfig = null // flavor별 signingConfig 사용
            
            // 난독화 및 최적화 활성화
            isMinifyEnabled = true
            isShrinkResources = true
            
            // ProGuard 규칙 적용
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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
    implementation("androidx.activity:activity-ktx:1.10.1")
    
    // AppCompat (권한 근거 화면용)
    implementation("androidx.appcompat:appcompat:1.6.1")
}
