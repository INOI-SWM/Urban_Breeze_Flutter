# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core (Flutter에서 사용)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Terra SDK
-keep class co.tryterra.** { *; }
-keepclassmembers class co.tryterra.** { *; }

# Gson - Terra SDK에서 사용
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Terra SDK 데이터 모델 클래스 보존
-keep class co.tryterra.terra.models.** { *; }
-keep class co.tryterra.terra.responses.** { *; }

# Kotlin 리플렉션
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Health Connect
-keep class androidx.health.connect.** { *; }
-keepclassmembers class androidx.health.connect.** { *; }

