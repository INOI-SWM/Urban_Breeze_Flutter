package com.inoi.urbanbreeze

import android.os.Bundle
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import com.inoi.urbanbreeze.healthconnect.HealthConnectPlugin
import com.inoi.urbanbreeze.healthconnect.HealthConnectManager

class MainActivity : FlutterFragmentActivity() {

    private lateinit var healthConnectManager: HealthConnectManager
    private lateinit var healthConnectPlugin: HealthConnectPlugin
    private lateinit var permissionLauncher: ActivityResultLauncher<Set<String>>
    private var permissionResultCallback: ((Boolean) -> Unit)? = null

    // 요청할 Health Connect 권한 목록
    private val permissions = setOf(
        HealthPermission.getReadPermission(ExerciseSessionRecord::class),
        HealthPermission.getReadPermission(HeartRateRecord::class),
        HealthPermission.getReadPermission(DistanceRecord::class),
        HealthPermission.getReadPermission(TotalCaloriesBurnedRecord::class),
        HealthPermission.getReadPermission(SpeedRecord::class),
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Health Connect Manager 초기화
        healthConnectManager = HealthConnectManager(this)

        // registerForActivityResult는 반드시 onCreate에서 호출
        permissionLauncher = registerForActivityResult(
            PermissionController.createRequestPermissionResultContract()
        ) { granted ->
            val allGranted = granted.containsAll(permissions)
            permissionResultCallback?.invoke(allGranted)
            permissionResultCallback = null
            
            // Health Connect Manager에 결과 전달
            if (allGranted) {
                healthConnectManager.onPermissionGranted()
            } else {
                healthConnectManager.onPermissionDenied()
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Health Connect Plugin 등록
        healthConnectPlugin = HealthConnectPlugin(this)
        healthConnectPlugin.setActivity(this)
        flutterEngine.plugins.add(healthConnectPlugin)
    }
    
    /**
     * Health Connect 권한 요청 (Plugin에서 호출)
     */
    fun requestHealthConnectPermissions(callback: (Boolean) -> Unit) {
        permissionResultCallback = callback
        permissionLauncher.launch(permissions)
    }
}
