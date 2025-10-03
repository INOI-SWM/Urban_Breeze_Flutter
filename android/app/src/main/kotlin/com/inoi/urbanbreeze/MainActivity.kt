package com.inoi.urbanbreeze

import android.os.Bundle
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
// import com.inoi.urbanbreeze.healthconnect.HealthConnectPlugin
// import com.inoi.urbanbreeze.healthconnect.HealthConnectManager

class MainActivity : FlutterFragmentActivity() {

    // private lateinit var healthConnectManager: HealthConnectManager
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

        // registerForActivityResult는 반드시 onCreate에서 호출
        permissionLauncher = registerForActivityResult(
            PermissionController.createRequestPermissionResultContract()
        ) { granted ->
            val allGranted = granted.containsAll(permissions)
            permissionResultCallback?.invoke(allGranted)
            permissionResultCallback = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Health Connect 매니저 초기화
        healthConnectManager = HealthConnectManager(this)

        // 플러그인 연결
        val plugin = HealthConnectPlugin()
        flutterEngine.plugins.add(plugin)

        // 플러그인에 Activity 전달
        plugin.setActivity(this)
    }

    /**
     * 외부에서 권한 요청을 트리거할 수 있게 함수 제공
     */
    fun requestHealthConnectPermissions(callback: (Boolean) -> Unit) {
        permissionResultCallback = callback
        permissionLauncher.launch(permissions)
    }

    fun getHealthConnectManager(): HealthConnectManager {
        return healthConnectManager
    }
}
