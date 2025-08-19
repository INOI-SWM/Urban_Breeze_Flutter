package com.inoi.urban_breeze.dev.healthconnect

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.HealthConnectClient.Companion.SDK_AVAILABLE
import androidx.health.connect.client.HealthConnectClient.Companion.SDK_UNAVAILABLE
import androidx.health.connect.client.HealthConnectClient.Companion.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class HealthConnectManager(private val context: Context) {

    private val TAG = "HealthConnectManager"
    private var healthConnectClient: HealthConnectClient? = null
    private var isInitialized = false

    private val coroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()

    init {
        initializeHealthConnect()
    }

    private fun initializeHealthConnect() {
        try {
            if (isHealthConnectAvailable()) {
                healthConnectClient = HealthConnectClient.getOrCreate(context)
                isInitialized = true
                Log.d(TAG, "Health Connect initialized successfully")
            } else {
                isInitialized = false
                Log.w(TAG, "Health Connect not available on this device")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize Health Connect: ${e.message}")
            isInitialized = false
            healthConnectClient = null
        }
    }

    fun isHealthConnectAvailable(): Boolean {
        return try {
            val apiLevel = android.os.Build.VERSION.SDK_INT
            if (apiLevel < 26) return false

            when (HealthConnectClient.getSdkStatus(context)) {
                SDK_AVAILABLE -> true
                SDK_UNAVAILABLE,
                SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED -> false
                else -> false
            }
        } catch (e: Exception) {
            false
        }
    }

    fun getClient(): HealthConnectClient? = healthConnectClient
    fun isInitialized(): Boolean = isInitialized && healthConnectClient != null
    fun getExecutor(): ExecutorService = executor
    fun getCoroutineScope(): CoroutineScope = coroutineScope

    fun cleanup() {
        try {
            coroutineScope.cancel()
            if (!executor.isShutdown) executor.shutdown()
            healthConnectClient = null
            isInitialized = false
        } catch (e: Exception) {
            Log.w(TAG, "Cleanup failed: ${e.message}")
        }
    }

    fun getStatusInfo(): String {
        return """
            Health Connect Manager Status:
            - Available: ${isHealthConnectAvailable()}
            - Initialized: $isInitialized
            - Client: ${if (healthConnectClient != null) "Available" else "Null"}
            - Executor: ${if (executor.isShutdown) "Shutdown" else "Active"}
        """.trimIndent()
    }

    fun createHealthConnectSettingsIntent(): Intent? {
        return try {
            val apiLevel = android.os.Build.VERSION.SDK_INT
            if (apiLevel < 26) return createPlayStoreIntent()

            val packageName = "com.google.android.apps.healthdata"
            val packageInfo = context.packageManager.getPackageInfo(packageName, 0)

            // 직접 설정으로 이동
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("healthconnect://settings")
                setPackage(packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            if (context.packageManager.resolveActivity(intent, 0) != null) {
                return intent
            }

            // 다른 대안
            val altIntent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("healthconnect://permissions")
                setPackage(packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            if (context.packageManager.resolveActivity(altIntent, 0) != null) {
                return altIntent
            }

            // 앱 메인으로
            context.packageManager.getLaunchIntentForPackage(packageName)?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            } ?: createPlayStoreIntent()

        } catch (e: Exception) {
            createPlayStoreIntent()
        }
    }

    fun createPlayStoreIntent(): Intent {
        return Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse("market://details?id=com.google.android.apps.healthdata")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
    }

    /**
     * ✅ 권한 요청 성공 시 호출 (MainActivity에서 호출됨)
     */
    fun onPermissionGranted() {
        Log.i(TAG, "Health Connect permission granted")
        // TODO: Flutter로 콜백 전달 또는 상태 업데이트 등 처리
    }

    /**
     * ❌ 권한 요청 실패 시 호출 (MainActivity에서 호출됨)
     */
    fun onPermissionDenied() {
        Log.w(TAG, "Health Connect permission denied")
        // TODO: Flutter로 콜백 전달 또는 사용자에게 안내
    }
}
