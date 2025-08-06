package com.inoi.ridingmate.dev.healthconnect.providers

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.health.connect.client.records.ExerciseRouteResult
import com.inoi.ridingmate.dev.healthconnect.HealthConnectManager
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch


/**
 * GPS 위치 데이터 전용 프로바이더
 * 
 * Health Connect에서 위치 데이터만을 전담하여 처리
 * 자전거 운동 경로 추적에 특화
 */
class LocationDataProvider(
    private val context: Context,
    private val healthConnectManager: HealthConnectManager
) {
    private val TAG = "LocationDataProvider"
    private val coroutineScope = healthConnectManager.getCoroutineScope()



    /**
     * 특정 운동 세션의 GPS 위치 데이터 조회
     * 
     * @param sessionId 운동 세션 ID
     * @param result Flutter 결과 콜백
     */
    fun getLocationDataForSession(sessionId: String, result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                val data = fetchLocationDataForSession(sessionId)
                result.success(data)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error fetching location data for session: ${e.message}")
                result.error("SESSION_LOCATION_ERROR", e.message, null)
            }
        }
    }


    /**
     * 운동 세션에서 경로 데이터 추출
     * 
     * @param client Health Connect 클라이언트
     * @param exerciseRecord 운동 세션 레코드
     * @return 위치 데이터 목록
     */
    private suspend fun extractRouteFromExerciseSession(
        client: HealthConnectClient,
        exerciseRecord: ExerciseSessionRecord
    ): List<Map<String, Any>> {
        val routeLocations = mutableListOf<Map<String, Any>>()
        
        try {
                when (val exerciseRouteResult = exerciseRecord.exerciseRouteResult) {
                    is ExerciseRouteResult.Data -> {
                        // 경로 데이터가 있는 경우
                        val exerciseRoute = exerciseRouteResult.exerciseRoute
                        val locations = exerciseRoute.route.orEmpty()
                        
                        for (location in locations) {
                            val locationMap = convertRouteLocationToMap(location, exerciseRecord.metadata.id)
                            routeLocations.add(locationMap)
                        }
                    }
                    is ExerciseRouteResult.ConsentRequired -> {
                        android.util.Log.d(TAG, "Consent required for route data in session ${exerciseRecord.metadata.id}")
                        // TODO: 사용자에게 경로 데이터 접근 권한 요청 UI 표시
                        // 현재는 로그만 출력하고 빈 데이터 반환
                    }
                    is ExerciseRouteResult.NoData -> {
                        android.util.Log.d(TAG, "No route data for session ${exerciseRecord.metadata.id}")
                    }
                    else -> {
                        android.util.Log.d(TAG, "Unknown route result type for session ${exerciseRecord.metadata.id}")
                    }
                }
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Error extracting route from exercise session: ${e.message}")
        }
        
        return routeLocations
    }

    /**
     * 특정 세션의 위치 데이터 조회
     * 
     * @param sessionId 세션 ID
     * @return 위치 데이터 목록
     */
    private suspend fun fetchLocationDataForSession(sessionId: String): List<Map<String, Any>> {
        val routeLocations = mutableListOf<Map<String, Any>>()
        
        try {
            val client = healthConnectManager.getClient()
            
            if (client == null) {
                android.util.Log.w(TAG, "Health Connect client not available")
                return routeLocations
            }

            // 권한 확인 (기본 권한 체크)
            try {
                val grantedPermissions = client.permissionController.getGrantedPermissions()
            } catch (e: Exception) {
                android.util.Log.w(TAG, "Permission check failed: ${e.message}")
            }

            // 특정 세션 ID로 운동 세션 조회
            val exerciseRecord = client.readRecord(ExerciseSessionRecord::class, sessionId)
            android.util.Log.d(TAG, "Exercise record: ${exerciseRecord.record}")
            
            // 해당 세션의 경로 데이터 추출
            val sessionRouteLocations = extractRouteFromExerciseSession(client, exerciseRecord.record)
            routeLocations.addAll(sessionRouteLocations)
            
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Error fetching location data for session $sessionId: ${e.message}")
        }
        
        return routeLocations
    }

    /**
     * 경로 위치를 Map으로 변환
     * 
     * @param location 경로 위치
     * @param sessionId 세션 ID
     * @return Flutter에서 사용할 Map 형태 데이터
     */
    private fun convertRouteLocationToMap(location: Any, sessionId: String): Map<String, Any> {
        // TODO: Health Connect 1.1.0-alpha12에서 실제 Location 타입 확인 필요
        // 현재는 임시로 기본 데이터 반환
        return mapOf(
            "timestamp" to System.currentTimeMillis(),
            "latitude" to 0.0,
            "longitude" to 0.0,
            "altitude" to 0.0,
            "accuracy" to 0.0,
            "source" to "unknown",
            "type" to "route",
            "sessionId" to sessionId
        )
    }
} 