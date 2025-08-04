package com.inoi.ridingmate.dev.healthconnect

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.HealthConnectClient.Companion.SDK_AVAILABLE
import androidx.health.connect.client.HealthConnectClient.Companion.SDK_UNAVAILABLE
import androidx.health.connect.client.HealthConnectClient.Companion.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.util.concurrent.Executors
import java.util.concurrent.ExecutorService

/**
 * Health Connect 클라이언트 관리자
 * 
 * Health Connect 클라이언트의 생명주기를 관리하고
 * 가용성 확인, 초기화, 정리 작업을 담당
 */
class HealthConnectManager(private val context: Context) {
    private val TAG = "HealthConnectManager"
    
    private var healthConnectClient: HealthConnectClient? = null
    private var isInitialized = false
    
    // 코루틴 스코프 (비동기 작업용)
    private val coroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    
    // ExecutorService (Java 호환성용)
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()

    init {
        initializeHealthConnect()
    }

    /**
     * Health Connect 초기화
     */
    private fun initializeHealthConnect() {
        try {
            if (isHealthConnectAvailable()) {
                healthConnectClient = HealthConnectClient.getOrCreate(context)
                isInitialized = true
                android.util.Log.d(TAG, "Health Connect client initialized successfully")
            } else {
                android.util.Log.w(TAG, "Health Connect not available on this device")
                isInitialized = false
            }
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Failed to initialize Health Connect: ${e.message}")
            isInitialized = false
            healthConnectClient = null
        }
    }

    /**
     * Health Connect 가용성 확인
     * 
     * @return Health Connect 사용 가능 여부
     */
    fun isHealthConnectAvailable(): Boolean {
        return try {
            val sdkStatus = HealthConnectClient.getSdkStatus(context)
            when (sdkStatus) {
                SDK_AVAILABLE -> true
                SDK_UNAVAILABLE -> false
                SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED -> false
                else -> false
            }
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Error checking Health Connect availability: ${e.message}")
            false
        }
    }

    /**
     * Health Connect 클라이언트 반환
     * 
     * @return Health Connect 클라이언트 (null일 수 있음)
     */
    fun getClient(): HealthConnectClient? {
        return healthConnectClient
    }

    /**
     * 초기화 상태 확인
     * 
     * @return 초기화 완료 여부
     */
    fun isInitialized(): Boolean {
        return isInitialized && healthConnectClient != null
    }

    /**
     * Health Connect 설정 화면으로 이동하는 Intent 생성
     * 
     * @return 설정 화면 Intent (null일 수 있음)
     */
    fun createHealthConnectSettingsIntent(): Intent? {
        return try {
            healthConnectClient?.let { client ->
                // Health Connect 1.1.0-alpha12에서는 다른 방식으로 설정 화면 접근
                // 현재는 Play Store로 리다이렉트
                createPlayStoreIntent()
            }
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Failed to create Health Connect settings intent: ${e.message}")
            null
        }
    }

    /**
     * Google Play Store의 Health Connect 페이지로 이동하는 Intent 생성
     * 
     * @return Play Store Intent
     */
    fun createPlayStoreIntent(): Intent {
        return Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse("market://details?id=com.google.android.apps.healthdata")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
    }

    /**
     * ExecutorService 반환 (Java 호환성용)
     * 
     * @return ExecutorService
     */
    fun getExecutor(): ExecutorService {
        return executor
    }

    /**
     * 코루틴 스코프 반환
     * 
     * @return CoroutineScope
     */
    fun getCoroutineScope(): CoroutineScope {
        return coroutineScope
    }

    /**
     * 리소스 정리
     */
    fun cleanup() {
        try {
            coroutineScope.cancel()
            if (!executor.isShutdown) {
                executor.shutdown()
            }
            healthConnectClient = null
            isInitialized = false
            android.util.Log.d(TAG, "Health Connect manager cleaned up")
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Error during cleanup: ${e.message}")
        }
    }

    /**
     * 상태 정보 반환 (디버깅용)
     * 
     * @return 상태 정보 문자열
     */
    fun getStatusInfo(): String {
        return """
            Health Connect Manager Status:
            - Available: ${isHealthConnectAvailable()}
            - Initialized: $isInitialized
            - Client: ${if (healthConnectClient != null) "Available" else "Null"}
            - Executor: ${if (executor.isShutdown) "Shutdown" else "Active"}
        """.trimIndent()
    }
} 