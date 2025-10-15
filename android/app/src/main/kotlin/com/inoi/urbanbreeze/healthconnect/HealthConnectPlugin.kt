package com.inoi.urbanbreeze.healthconnect

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.inoi.urbanbreeze.healthconnect.providers.*

/**
 * Health Connect Flutter 플러그인
 * 
 * Flutter와 Health Connect 간의 MethodChannel 통신을 담당
 */
class HealthConnectPlugin(private var activity: Activity? = null) : FlutterPlugin, MethodCallHandler {
    private val CHANNEL = "health_connect"
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    
    // Health Connect 관리자들
    private lateinit var healthConnectManager: HealthConnectManager
    private lateinit var permissionManager: HealthConnectPermissionManager
    private lateinit var dataProvider: HealthConnectDataProvider
    private val coroutineScope = kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.Main)
    
    // 응답 코드 상수
    companion object {
        const val SUCCESS = "SUCCESS"
        const val ERROR_PERMISSION_DENIED = "PERMISSION_DENIED"
        const val ERROR_NOT_AVAILABLE = "NOT_AVAILABLE"
        const val ERROR_NO_DATA = "NO_DATA"
        const val ERROR_UNKNOWN = "UNKNOWN_ERROR"
        
        // 디버그 로그 헬퍼
        private fun logDebug(tag: String, message: String) {
            if (com.inoi.urbanbreeze.BuildConfig.DEBUG) {
                android.util.Log.d(tag, "🔍 $message")
            }
        }
        
        private fun logError(tag: String, message: String, e: Exception? = null) {
            if (com.inoi.urbanbreeze.BuildConfig.DEBUG) {
                if (e != null) {
                    android.util.Log.e(tag, "❌ $message", e)
                } else {
                    android.util.Log.e(tag, "❌ $message")
                }
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        
        // Health Connect 관리자들 초기화
        healthConnectManager = HealthConnectManager(context)
        permissionManager = HealthConnectPermissionManager(context, healthConnectManager)
        dataProvider = HealthConnectDataProvider(context, healthConnectManager)
    }
    
    /**
     * Activity 참조 설정
     */
    fun setActivity(activity: Activity) {
        this.activity = activity
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        logDebug("HealthConnectPlugin", "onMethodCall(): ${call.method}")
        
        try {
            when (call.method) {
                "isAvailable" -> handleIsAvailable(result)
                "requestPermissions" -> handleRequestPermissions(result)
                "hasPermissions" -> handleHasPermissions(result)
                "getExerciseSessions" -> handleGetExerciseSessions(call, result)
                "getHeartRateData" -> handleGetHeartRateData(call, result)
                "getDistanceData" -> handleGetDistanceData(call, result)
                "getLocationDataForSession" -> handleGetLocationDataForSession(call, result)
                else -> {
                    logError("HealthConnectPlugin", "구현되지 않은 메서드: ${call.method}")
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            logError("HealthConnectPlugin", "메서드 실행 중 오류 발생", e)
            result.error(ERROR_UNKNOWN, "예상치 못한 오류: ${e.message}", null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        healthConnectManager.cleanup()
    }

    // ===========================================
    // 기본 기능 핸들러들
    // ===========================================

    private fun handleIsAvailable(result: Result) {
        val isAvailable = healthConnectManager.isHealthConnectAvailable()
        result.success(isAvailable)
    }

    private fun handleRequestPermissions(result: Result) {
        logDebug("HealthConnectPlugin", "handleRequestPermissions() 호출")
        
        val mainActivity = activity as? com.inoi.urbanbreeze.MainActivity
        if (mainActivity != null) {
            // MainActivity의 권한 요청 사용
            mainActivity.requestHealthConnectPermissions { granted ->
                logDebug("HealthConnectPlugin", "권한 요청 결과: granted=$granted")
                
                if (granted) {
                    result.success(SUCCESS)
                } else {
                    result.error(ERROR_PERMISSION_DENIED, "사용자가 권한을 거부했습니다", null)
                }
            }
        } else {
            logError("HealthConnectPlugin", "MainActivity 참조를 찾을 수 없습니다")
            result.error(ERROR_UNKNOWN, "Activity 참조가 없습니다", null)
        }
    }

    private fun handleHasPermissions(result: Result) {
        try {
            val isAvailable = healthConnectManager.isHealthConnectAvailable()
            logDebug("HealthConnectPlugin", "hasPermissions() 결과: $isAvailable")
            result.success(isAvailable)
        } catch (e: Exception) {
            logError("HealthConnectPlugin", "권한 확인 실패", e)
            result.error(ERROR_UNKNOWN, "권한 확인 중 오류 발생: ${e.message}", null)
        }
    }

    // ===========================================
    // 데이터 조회 핸들러들
    // ===========================================

    private fun handleGetExerciseSessions(call: MethodCall, result: Result) {
        val startTime = call.argument<Long>("startTime")
        val endTime = call.argument<Long>("endTime")
        
        if (startTime == null || endTime == null) {
            result.error("INVALID_ARGUMENTS", "startTime and endTime are required", null)
            return
        }
        
        dataProvider.getExerciseSessions(startTime, endTime, result)
    }

    private fun handleGetHeartRateData(call: MethodCall, result: Result) {
        val startTime = call.argument<Long>("startTime")
        val endTime = call.argument<Long>("endTime")
        
        if (startTime == null || endTime == null) {
            result.error("INVALID_ARGUMENTS", "startTime and endTime are required", null)
            return
        }
        
        dataProvider.getHeartRateData(startTime, endTime, result)
    }



    private fun handleGetDistanceData(call: MethodCall, result: Result) {
        val startTime = call.argument<Long>("startTime")
        val endTime = call.argument<Long>("endTime")
        
        if (startTime == null || endTime == null) {
            result.error("INVALID_ARGUMENTS", "startTime and endTime are required", null)
            return
        }
        
        dataProvider.getDistanceData(startTime, endTime, result)
    }



    private fun handleGetLocationDataForSession(call: MethodCall, result: Result) {
        val sessionId = call.argument<String>("sessionId")
        
        if (sessionId.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENTS", "sessionId is required", null)
            return
        }
        
        dataProvider.getLocationDataForSession(sessionId, result)
    }


} 