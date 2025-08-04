package com.inoi.ridingmate.dev.healthconnect

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.inoi.ridingmate.dev.healthconnect.providers.*

/**
 * Health Connect Flutter 플러그인
 * 
 * Flutter와 Health Connect 간의 MethodChannel 통신을 담당
 */
class HealthConnectPlugin : FlutterPlugin, MethodCallHandler {
    private val CHANNEL = "health_connect"
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    
    // Health Connect 관리자들
    private lateinit var healthConnectManager: HealthConnectManager
    private lateinit var permissionManager: HealthConnectPermissionManager
    private lateinit var dataProvider: HealthConnectDataProvider
    private val coroutineScope = kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.Main)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        
        // Health Connect 관리자들 초기화
        healthConnectManager = HealthConnectManager(context)
        permissionManager = HealthConnectPermissionManager(context, healthConnectManager)
        dataProvider = HealthConnectDataProvider(context, healthConnectManager)
        
        android.util.Log.d("HealthConnectPlugin", "Health Connect plugin attached to engine")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "isAvailable" -> handleIsAvailable(result)
                "requestPermissions" -> handleRequestPermissions(result)
                "hasPermissions" -> handleHasPermissions(result)
                "getExerciseSessions" -> handleGetExerciseSessions(call, result)
                "getHeartRateData" -> handleGetHeartRateData(call, result)
                "getSpeedData" -> handleGetSpeedData(call, result)
                "getDistanceData" -> handleGetDistanceData(call, result)
                "getLocationData" -> handleGetLocationData(call, result)
                "getLocationDataForSession" -> handleGetLocationDataForSession(call, result)
                "getStatusInfo" -> handleGetStatusInfo(result)
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("PLUGIN_ERROR", "Unexpected error: ${e.message}", null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        healthConnectManager.cleanup()
        android.util.Log.d("HealthConnectPlugin", "Health Connect plugin detached from engine")
    }

    // ===========================================
    // 기본 기능 핸들러들
    // ===========================================

    private fun handleIsAvailable(result: Result) {
        val isAvailable = healthConnectManager.isHealthConnectAvailable()
        result.success(isAvailable)
    }

    private fun handleRequestPermissions(result: Result) {
        permissionManager.requestPermissions(result)
    }

    private fun handleHasPermissions(result: Result) {
        // 임시로 기본 가용성 체크만 수행
        try {
            val isAvailable = healthConnectManager.isHealthConnectAvailable()
            result.success(isAvailable)
        } catch (e: Exception) {
            result.error("PERMISSION_CHECK_ERROR", e.message, null)
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

    private fun handleGetSpeedData(call: MethodCall, result: Result) {
        val startTime = call.argument<Long>("startTime")
        val endTime = call.argument<Long>("endTime")
        
        if (startTime == null || endTime == null) {
            result.error("INVALID_ARGUMENTS", "startTime and endTime are required", null)
            return
        }
        
        dataProvider.getSpeedData(startTime, endTime, result)
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

    private fun handleGetLocationData(call: MethodCall, result: Result) {
        val startTime = call.argument<Long>("startTime")
        val endTime = call.argument<Long>("endTime")
        
        if (startTime == null || endTime == null) {
            result.error("INVALID_ARGUMENTS", "startTime and endTime are required", null)
            return
        }
        
        dataProvider.getLocationData(startTime, endTime, result)
    }

    private fun handleGetLocationDataForSession(call: MethodCall, result: Result) {
        val sessionId = call.argument<String>("sessionId")
        
        if (sessionId.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENTS", "sessionId is required", null)
            return
        }
        
        dataProvider.getLocationDataForSession(sessionId, result)
    }

    private fun handleGetStatusInfo(result: Result) {
        val statusInfo = healthConnectManager.getStatusInfo()
        result.success(statusInfo)
    }
} 