package com.inoi.ridingmate.dev.healthconnect

import android.content.Context
import android.content.Intent
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.*
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit

/**
 * Health Connect 권한 관리자
 * 
 * Health Connect 앱의 권한 요청, 상태 확인, 설정 화면 연결을 담당
 * Health Connect 1.1.0-alpha12 버전 기준
 */
class HealthConnectPermissionManager(
    private val context: Context,
    private val healthConnectManager: HealthConnectManager
) {
    private val TAG = "HealthConnectPermissionManager"
    private val coroutineScope = healthConnectManager.getCoroutineScope()

    /**
     * Health Connect 권한 요청
     * 
     * @param result Flutter 결과 콜백
     */
    fun requestPermissions(result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                if (!healthConnectManager.isHealthConnectAvailable()) {
                    result.error("NOT_AVAILABLE", "Health Connect is not available on this device", null)
                    return@launch
                }

                val client = healthConnectManager.getClient()
                if (client == null) {
                    result.error("CLIENT_ERROR", "Health Connect client not available", null)
                    return@launch
                }

                // 실제 권한 요청 (Health Connect 1.1.0-alpha12)
                val permissions = getRequiredHealthPermissions()
                val permissionController = client.permissionController
                
                // TODO: Health Connect 1.1.0-alpha12 권한 요청 API 통합
                // 현재는 설정 화면으로 리다이렉트
                android.util.Log.d(TAG, "Requesting Health Connect permissions (redirecting to settings)")
                redirectToHealthConnectSettings(result)
                
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Failed to request Health Connect permissions: ${e.message}")
                result.error("PERMISSION_ERROR", "Failed to request permissions: ${e.message}", null)
            }
        }
    }

    /**
     * Health Connect 권한 상태 확인
     * 
     * @return 권한 보유 여부
     */
    suspend fun hasPermissions(): Boolean {
        return withContext(Dispatchers.IO) {
            try {
                val client = healthConnectManager.getClient()
                if (client == null) {
                    return@withContext false
                }

                val permissionController = client.permissionController
                val requiredPermissions = getRequiredHealthPermissions()
                
                // TODO: Health Connect 1.1.0-alpha12 권한 확인 API 통합
                // 현재는 기본적인 가용성 체크로 대체
                android.util.Log.d(TAG, "Checking Health Connect permissions (basic availability check)")
                healthConnectManager.isHealthConnectAvailable()
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error checking permissions: ${e.message}")
                false
            }
        }
    }

    /**
     * 특정 권한 확인
     * 
     * @param permissionType 권한 타입
     * @return 권한 보유 여부
     */
    suspend fun hasPermission(permissionType: String): Boolean {
        return withContext(Dispatchers.IO) {
            try {
                val client = healthConnectManager.getClient()
                if (client == null) {
                    return@withContext false
                }

                val permissionController = client.permissionController
                val requiredPermissions = getRequiredHealthPermissions()
                
                // TODO: Health Connect 1.1.0-alpha12 개별 권한 확인 API 통합
                // 현재는 기본적인 가용성 체크로 대체
                android.util.Log.d(TAG, "Checking specific permission: $permissionType (basic availability check)")
                hasPermissions()
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error checking specific permission: ${e.message}")
                false
            }
        }
    }

    /**
     * Health Connect 설정 화면으로 리다이렉트
     * 
     * @param result Flutter 결과 콜백
     */
    fun redirectToHealthConnectSettings(result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                val intent = healthConnectManager.createHealthConnectSettingsIntent()
                
                if (intent != null) {
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
                    android.util.Log.d(TAG, "Redirected to Health Connect settings")
                    result.success("SUCCESS")
                } else {
                    redirectToPlayStore()
                    result.success("PLAY_STORE_REDIRECT")
                }
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Failed to redirect to Health Connect settings: ${e.message}")
                result.error("REDIRECT_ERROR", "Failed to redirect: ${e.message}", null)
            }
        }
    }

    /**
     * Google Play Store의 Health Connect 페이지로 리다이렉트
     */
    private fun redirectToPlayStore() {
        try {
            val intent = healthConnectManager.createPlayStoreIntent()
            context.startActivity(intent)
            android.util.Log.d(TAG, "Redirected to Play Store for Health Connect")
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Failed to redirect to Play Store: ${e.message}")
        }
    }

    /**
     * Health Connect 1.1.0-alpha12 필요한 권한 집합 생성
     * 
     * @return HealthPermission 집합
     */
    private fun getRequiredHealthPermissions(): Set<HealthPermission> {
        // TODO: Health Connect 1.1.0-alpha12 실제 권한 추가
        // 현재는 API 호환성 문제로 빈 집합 반환
        return emptySet()
    }

    /**
     * 권한 관련 상태 정보 반환 (디버깅용)
     * 
     * @return 권한 상태 정보 문자열
     */
    suspend fun getPermissionStatusInfo(): String {
        return """
            Health Connect Permission Status (v1.1.0-alpha12):
            - Health Connect Available: ${healthConnectManager.isHealthConnectAvailable()}
            - Has Basic Permissions: ${hasPermissions()}
            - Manager Initialized: ${healthConnectManager.isInitialized()}
            - Client Available: ${if (healthConnectManager.getClient() != null) "Yes" else "No"}
        """.trimIndent()
    }

    /**
     * 필요한 권한 목록 반환 (참고용)
     * 
     * @return Health Connect에서 필요한 권한들
     */
    fun getRequiredPermissions(): Array<String> {
        return arrayOf(
            "android.permission.health.READ_EXERCISE",
            "android.permission.health.WRITE_EXERCISE", 
            "android.permission.health.READ_HEART_RATE",
            "android.permission.health.WRITE_HEART_RATE",
            "android.permission.health.READ_SPEED",
            "android.permission.health.READ_DISTANCE",
            "android.permission.health.READ_TOTAL_CALORIES_BURNED",
            "android.permission.health.READ_HEALTH_DATA_HISTORY",
            "android.permission.ACTIVITY_RECOGNITION"
        )
    }

    /**
     * 권한 상태 자세히 확인
     * 
     * @return 각 권한별 상태 맵
     */
    suspend fun getDetailedPermissionStatus(): Map<String, Boolean> {
        return withContext(Dispatchers.IO) {
            val permissionStatus = mutableMapOf<String, Boolean>()
            
            try {
                val client = healthConnectManager.getClient()
                if (client == null) {
                    // 클라이언트가 없으면 모든 권한을 false로 설정
                    getRequiredPermissions().forEach { permission ->
                        permissionStatus[permission] = false
                    }
                    return@withContext permissionStatus
                }

                val permissionController = client.permissionController
                val requiredPermissions = getRequiredHealthPermissions()
                
                // TODO: Health Connect 1.1.0-alpha12 개별 권한 상태 확인 API 통합
                // 현재는 기본값으로 설정
                val hasBasicPermissions = hasPermissions()
                getRequiredPermissions().forEach { permission ->
                    permissionStatus[permission] = hasBasicPermissions
                }
                
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error getting detailed permission status: ${e.message}")
                getRequiredPermissions().forEach { permission ->
                    permissionStatus[permission] = false
                }
            }
            
            permissionStatus
        }
    }
} 