package com.inoi.urbanbreeze.healthconnect.providers

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.health.connect.client.records.ExerciseRouteResult
import androidx.health.connect.client.records.ExerciseRoute
import com.inoi.urbanbreeze.healthconnect.HealthConnectManager
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext


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
                        
                        android.util.Log.d(TAG, "Found ${locations.size} location points in exercise route")
                        
                        for (location in locations) {
                            val locationMap = convertRouteLocationToMap(location, exerciseRecord.metadata.id)
                            routeLocations.add(locationMap)
                        }
                    }
                    is ExerciseRouteResult.ConsentRequired -> {
                        // 경로 데이터 접근에 추가 권한 필요
                        android.util.Log.w(TAG, "Consent required for exercise route data. User needs to grant additional permission.")
                        // Flutter에서 처리: 빈 리스트 반환하고 에러는 발생시키지 않음
                    }
                    is ExerciseRouteResult.NoData -> {
                        // 경로 데이터가 없는 운동 세션
                        android.util.Log.d(TAG, "No route data available for this exercise session")
                    }
                    else -> {
                        android.util.Log.w(TAG, "Unknown ExerciseRouteResult type")
                    }
                }
        } catch (e: Exception) {
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
        return withContext(Dispatchers.IO) {
            val routeLocations = mutableListOf<Map<String, Any>>()
            
            try {
                val client = healthConnectManager.getClient()
                
                if (client == null) {
                    android.util.Log.w(TAG, "Health Connect client is null")
                    return@withContext routeLocations
                }

                // 특정 세션 ID로 운동 세션 조회
                val exerciseRecord = client.readRecord(ExerciseSessionRecord::class, sessionId)
                
                // 해당 세션의 경로 데이터 추출
                val sessionRouteLocations = extractRouteFromExerciseSession(client, exerciseRecord.record)
                routeLocations.addAll(sessionRouteLocations)
                
                android.util.Log.d(TAG, "Fetched ${routeLocations.size} location points for session $sessionId")
                
            } catch (e: SecurityException) {
                // 권한 없음
                android.util.Log.w(TAG, "Location permission not granted for session $sessionId")
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error fetching location data for session $sessionId: ${e.message}")
            }
            
            routeLocations
        }
    }

    /**
     * 경로 위치를 Map으로 변환
     * 
     * @param location 경로 위치 (ExerciseRoute.Location)
     * @param sessionId 세션 ID
     * @return Flutter에서 사용할 Map 형태 데이터
     */
    private fun convertRouteLocationToMap(location: ExerciseRoute.Location, sessionId: String): Map<String, Any> {
        return mapOf(
            "timestamp" to location.time.toEpochMilli(),
            "latitude" to location.latitude,
            "longitude" to location.longitude,
            "altitude" to (location.altitude?.inMeters ?: 0.0),
            "accuracy" to (location.horizontalAccuracy?.inMeters ?: 0.0),
            "verticalAccuracy" to (location.verticalAccuracy?.inMeters ?: 0.0),
            "type" to "route",
            "sessionId" to sessionId
        )
    }
} 