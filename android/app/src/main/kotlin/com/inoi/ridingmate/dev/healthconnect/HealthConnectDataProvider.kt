package com.inoi.ridingmate.dev.healthconnect

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import com.inoi.ridingmate.dev.healthconnect.providers.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Health Connect 데이터 제공자
 * 
 * 모든 Health Connect 데이터 조회의 통합 진입점
 * 개별 데이터 프로바이더들을 관리하고 공통 로직을 처리
 */
class HealthConnectDataProvider(
    private val context: Context,
    private val healthConnectManager: HealthConnectManager
) {
    private val TAG = "HealthConnectDataProvider"
    private val coroutineScope = healthConnectManager.getCoroutineScope()
    
    // 개별 데이터 프로바이더들
    private val exerciseDataProvider = ExerciseDataProvider(context, healthConnectManager)
    private val heartRateDataProvider = HeartRateDataProvider(context, healthConnectManager)
    private val distanceDataProvider = DistanceDataProvider(context, healthConnectManager)
    private val locationDataProvider = LocationDataProvider(context, healthConnectManager)

    /**
     * 운동 세션 데이터 조회
     * 
     * @param startTime 시작 시간 (밀리초)
     * @param endTime 종료 시간 (밀리초)
     * @param result Flutter 결과 콜백
     */
    fun getExerciseSessions(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        if (!validateTimeRange(startTime, endTime, result)) {
            return
        }
        
        if (!healthConnectManager.isInitialized()) {
            result.error("NOT_INITIALIZED", "Health Connect not initialized", null)
            return
        }

        android.util.Log.d(TAG, "Getting exercise sessions from $startTime to $endTime")
        exerciseDataProvider.getExerciseSessions(startTime, endTime, result)
    }

    /**
     * 심박수 데이터 조회
     * 
     * @param startTime 시작 시간 (밀리초)
     * @param endTime 종료 시간 (밀리초)
     * @param result Flutter 결과 콜백
     */
    fun getHeartRateData(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        if (!validateTimeRange(startTime, endTime, result)) {
            return
        }
        
        if (!healthConnectManager.isInitialized()) {
            result.error("NOT_INITIALIZED", "Health Connect not initialized", null)
            return
        }

        heartRateDataProvider.getHeartRateData(startTime, endTime, result)
    }



    /**
     * 거리 데이터 조회
     * 
     * @param startTime 시작 시간 (밀리초)
     * @param endTime 종료 시간 (밀리초)
     * @param result Flutter 결과 콜백
     */
    fun getDistanceData(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        if (!validateTimeRange(startTime, endTime, result)) {
            return
        }
        
        if (!healthConnectManager.isInitialized()) {
            result.error("NOT_INITIALIZED", "Health Connect not initialized", null)
            return
        }

        distanceDataProvider.getDistanceData(startTime, endTime, result)
    }

    /**
     * GPS 위치 데이터 조회
     * 
     * @param startTime 시작 시간 (밀리초)
     * @param endTime 종료 시간 (밀리초)
     * @param result Flutter 결과 콜백
     */
    fun getLocationData(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        if (!validateTimeRange(startTime, endTime, result)) {
            return
        }
        
        if (!healthConnectManager.isInitialized()) {
            result.error("NOT_INITIALIZED", "Health Connect not initialized", null)
            return
        }

        locationDataProvider.getLocationData(startTime, endTime, result)
    }



    /**
     * 시간 범위 유효성 검사
     * 
     * @param startTime 시작 시간
     * @param endTime 종료 시간
     * @param result Flutter 결과 콜백
     * @return 유효성 검사 통과 여부
     */
    private fun validateTimeRange(startTime: Long, endTime: Long, result: MethodChannel.Result): Boolean {
        if (startTime >= endTime) {
            result.error("INVALID_TIME_RANGE", "startTime must be before endTime", null)
            return false
        }
        
        // 최대 1년 범위로 제한 (필요에 따라 조정)
        val maxRangeMillis = 365L * 24 * 60 * 60 * 1000 // 1년
        if (endTime - startTime > maxRangeMillis) {
            result.error("TIME_RANGE_TOO_LARGE", "Time range cannot exceed 1 year", null)
            return false
        }
        
        // 미래 시간 체크
        val currentTime = System.currentTimeMillis()
        if (startTime > currentTime || endTime > currentTime) {
            result.error("FUTURE_TIME_NOT_ALLOWED", "Cannot query future time ranges", null)
            return false
        }
        
        return true
    }

    /**
     * 상태 정보 반환 (디버깅용)
     * 
     * @return 상태 정보 문자열
     */
    fun getStatusInfo(): String {
        return """
            Health Connect Data Provider Status:
            - Manager Status: ${healthConnectManager.getStatusInfo()}
            - Exercise Provider: Available
            - Heart Rate Provider: Available
            - Speed Provider: Available
            - Distance Provider: Available
            - Location Provider: Available
        """.trimIndent()
    }

    /**
     * 리소스 정리
     */
    fun cleanup() {
        try {
            // 개별 프로바이더들의 정리 작업이 필요한 경우 여기에 추가
            android.util.Log.d(TAG, "Health Connect data provider cleaned up")
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Error during cleanup: ${e.message}")
        }
    }
} 