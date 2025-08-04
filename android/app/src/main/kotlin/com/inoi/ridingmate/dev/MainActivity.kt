package com.inoi.ridingmate.dev

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.inoi.ridingmate.dev.healthconnect.HealthConnectPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Health Connect 플러그인 등록
        flutterEngine.plugins.add(HealthConnectPlugin())
    }
} 