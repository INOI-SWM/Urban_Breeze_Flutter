package com.inoi.urbanbreeze

import android.os.Bundle
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.TotalCaloriesBurnedRecord
import androidx.health.connect.client.records.SpeedRecord
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import com.inoi.urbanbreeze.healthconnect.HealthConnectPlugin
import com.inoi.urbanbreeze.healthconnect.HealthConnectManager

class MainActivity : FlutterFragmentActivity() {

    private lateinit var healthConnectManager: HealthConnectManager
    private lateinit var healthConnectPlugin: HealthConnectPlugin
    private lateinit var permissionLauncher: ActivityResultLauncher<Set<String>>
    private var permissionResultCallback: ((Boolean, List<String>) -> Unit)? = null

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
            val deniedList = permissions.filter { !granted.contains(it) }
            
            permissionResultCallback?.invoke(allGranted, deniedList)
            permissionResultCallback = null
            
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
     * 
     * @param callback 권한 결과 콜백 (allGranted, deniedPermissions)
     */
    fun requestHealthConnectPermissions(callback: (Boolean, List<String>) -> Unit) {
        permissionResultCallback = callback
        permissionLauncher.launch(permissions)
    }
}
