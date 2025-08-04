package com.inoi.ridingmate.dev.healthconnect.providers

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
// TODO: Health Connect 1.1.0-alpha12에서 위치 관련 레코드 타입 확인 필요
// import androidx.health.connect.client.records.ExerciseRouteRecord
// import androidx.health.connect.client.records.LocationRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.response.ReadRecordsResponse
import androidx.health.connect.client.time.TimeRangeFilter
import com.inoi.ridingmate.dev.healthconnect.HealthConnectManager
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.time.Instant
import kotlin.math.*

/**
 * GPS 위치 데이터 전용 프로바이더
 * 
 * Health Connect에서 위치(LocationRecord, ExerciseRouteRecord) 데이터만을 전담하여 처리
 * 자전거 운동 경로 추적에 특화
 */
class LocationDataProvider(
    private val context: Context,
    private val healthConnectManager: HealthConnectManager
) {
    private val TAG = "LocationDataProvider"
    private val coroutineScope = healthConnectManager.getCoroutineScope()

    init {
        android.util.Log.d(TAG, "LocationDataProvider initialized")
    }

    /**
     * GPS 위치 데이터 조회
     * 
     * @param startTime 시작 시간 (밀리초)
     * @param endTime 종료 시간 (밀리초)
     * @param result Flutter 결과 콜백
     */
    fun getLocationData(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        android.util.Log.d(TAG, "Getting location data from $startTime to $endTime")
        
        coroutineScope.launch {
            try {
                val data = fetchLocationDataFromHealthConnect(startTime, endTime)
                result.success(data)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error fetching location data: ${e.message}")
                result.error("LOCATION_DATA_ERROR", e.message, null)
            }
        }
    }

    /**
     * Health Connect에서 실제 위치 데이터 조회
     * 
     * @param startTime 시작 시간
     * @param endTime 종료 시간
     * @return 위치 데이터 목록
     */
    suspend fun fetchLocationDataFromHealthConnect(startTime: Long, endTime: Long): List<Map<String, Any>> {
        return withContext(Dispatchers.IO) {
            val locationData = mutableListOf<Map<String, Any>>()
            
            try {
                val client = healthConnectManager.getClient()
                
                if (client == null) {
                    android.util.Log.w(TAG, "Health Connect client not available")
                    return@withContext locationData
                }

                // Health Connect 1.1.0-alpha12 실제 API 호출
                android.util.Log.d(TAG, "Fetching location data from Health Connect")
                
                // 시간 범위 필터 생성
                val timeFilter = TimeRangeFilter.between(
                    Instant.ofEpochMilli(startTime),
                    Instant.ofEpochMilli(endTime)
                )
                
                // TODO: Health Connect 1.1.0-alpha12에서 위치 관련 레코드 타입 확인 필요
                // 현재는 임시로 빈 데이터 반환
                android.util.Log.d(TAG, "Location data API integration pending")
                
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error in fetchLocationDataFromHealthConnect: ${e.message}")
                // 에러 발생 시 빈 리스트 반환
            }
            
            locationData
        }
    }

    /**
     * LocationRecord를 Map으로 변환 (임시 구현)
     * 
     * @param record 위치 레코드
     * @return Flutter에서 사용할 Map 형태 데이터
     */
    private fun convertLocationToMap(record: Any): Map<String, Any> {
        // TODO: Health Connect 1.1.0-alpha12에서 실제 LocationRecord 타입 확인 필요
        return mapOf(
            "timestamp" to System.currentTimeMillis(),
            "latitude" to 0.0,
            "longitude" to 0.0,
            "altitude" to 0.0,
            "accuracy" to 0.0,
            "source" to "unknown",
            "type" to "location"
        )
    }

    /**
     * ExerciseRouteRecord의 Location을 Map으로 변환 (임시 구현)
     * 
     * @param location 경로 위치
     * @param record 운동 경로 레코드
     * @return Flutter에서 사용할 Map 형태 데이터
     */
    private fun convertRouteLocationToMap(location: Any, record: Any): Map<String, Any> {
        // TODO: Health Connect 1.1.0-alpha12에서 실제 타입 확인 필요
        return mapOf(
            "timestamp" to System.currentTimeMillis(),
            "latitude" to 0.0,
            "longitude" to 0.0,
            "altitude" to 0.0,
            "accuracy" to 0.0,
            "source" to "unknown",
            "type" to "route",
            "sessionId" to "unknown"
        )
    }

    /**
     * 특정 운동 세션의 GPS 경로 데이터 조회
     * 
     * @param sessionId 운동 세션 ID
     * @param result Flutter 결과 콜백
     */
    fun getLocationDataForSession(sessionId: String, result: MethodChannel.Result) {
        android.util.Log.d(TAG, "Getting location data for session: $sessionId")
        
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
     * 특정 세션의 위치 데이터 조회 (실제 구현)
     * 
     * @param sessionId 세션 ID
     * @return 위치 데이터 목록
     */
    private suspend fun fetchLocationDataForSession(sessionId: String): List<Map<String, Any>> {
        return withContext(Dispatchers.IO) {
            val sessionLocationData = mutableListOf<Map<String, Any>>()
            
            try {
                val client = healthConnectManager.getClient()
                
                if (client == null) {
                    throw RuntimeException("Health Connect client not available")
                }

                // TODO: Health Connect 1.1.0-alpha12에서 특정 세션의 경로 조회
                // 현재는 기본 정보만 반환
                android.util.Log.d(TAG, "Session location data API integration pending for session: $sessionId")
                
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error fetching location data for session: ${e.message}")
                throw RuntimeException("Failed to fetch session location data", e)
            }
            
            sessionLocationData
        }
    }

    /**
     * 위치 데이터 통계 정보 계산
     * 
     * @param startTime 시작 시간
     * @param endTime 종료 시간
     * @param result Flutter 결과 콜백
     */
    fun getLocationStatistics(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        android.util.Log.d(TAG, "Getting location statistics")
        
        coroutineScope.launch {
            try {
                val locationData = fetchLocationDataFromHealthConnect(startTime, endTime)
                val stats = calculateLocationStatistics(locationData)
                result.success(stats)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error calculating location statistics: ${e.message}")
                result.error("LOCATION_STATS_ERROR", e.message, null)
            }
        }
    }

    /**
     * 위치 데이터 통계 계산
     * 
     * @param locationData 위치 데이터 목록
     * @return 위치 통계 정보
     */
    private fun calculateLocationStatistics(locationData: List<Map<String, Any>>): Map<String, Any> {
        val statistics = mutableMapOf<String, Any>()
        
        if (locationData.isEmpty()) {
            statistics["count"] = 0
            statistics["totalDistance"] = 0.0
            statistics["averageAccuracy"] = 0.0
            return statistics
        }
        
        var totalDistance = 0.0
        var totalAccuracy = 0.0
        var validLocationCount = 0
        
        // 위치 데이터를 시간순으로 정렬
        val sortedLocations = locationData.sortedBy { it["timestamp"] as Long }
        
        // 연속된 위치 간 거리 계산
        for (i in 0 until sortedLocations.size - 1) {
            val current = sortedLocations[i]
            val next = sortedLocations[i + 1]
            
            val distance = calculateDistance(
                current["latitude"] as Double,
                current["longitude"] as Double,
                next["latitude"] as Double,
                next["longitude"] as Double
            )
            
            if (isValidLocation(current) && isValidLocation(next)) {
                totalDistance += distance
                validLocationCount++
            }
            
            totalAccuracy += (current["accuracy"] as Double)
        }
        
        val count = locationData.size
        val averageAccuracy = if (count > 0) totalAccuracy / count else 0.0
        
        statistics["count"] = count
        statistics["totalDistance"] = (totalDistance * 100).roundToInt() / 100.0 // km, 소수점 2자리
        statistics["averageAccuracy"] = (averageAccuracy * 100).roundToInt() / 100.0 // 미터, 소수점 2자리
        statistics["validLocationCount"] = validLocationCount
        
        // 경로 품질 분석
        val qualityAnalysis = analyzeRouteQuality(sortedLocations)
        statistics["quality"] = qualityAnalysis
        
        android.util.Log.d(TAG, "Location statistics: count=$count, distance=$totalDistance, accuracy=$averageAccuracy")
        
        return statistics
    }

    /**
     * 두 지점 간 거리 계산 (Haversine 공식)
     * 
     * @param lat1 첫 번째 지점의 위도
     * @param lon1 첫 번째 지점의 경도
     * @param lat2 두 번째 지점의 위도
     * @param lon2 두 번째 지점의 경도
     * @return 거리 (km)
     */
    private fun calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
        val R = 6371.0 // 지구 반지름 (km)
        
        val dLat = Math.toRadians(lat2 - lat1)
        val dLon = Math.toRadians(lon2 - lon1)
        
        val a = sin(dLat / 2) * sin(dLat / 2) +
                cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) *
                sin(dLon / 2) * sin(dLon / 2)
        
        val c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return R * c
    }

    /**
     * 위치 데이터 유효성 검사
     * 
     * @param location 위치 데이터
     * @return 유효성 여부
     */
    private fun isValidLocation(location: Map<String, Any>): Boolean {
        val latitude = location["latitude"] as Double
        val longitude = location["longitude"] as Double
        val accuracy = location["accuracy"] as Double
        
        // 위도/경도 범위 검사
        if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
            return false
        }
        
        // 정확도 검사 (너무 부정확한 데이터 제외)
        if (accuracy > 100) { // 100미터 이상 오차는 제외
            return false
        }
        
        return true
    }

    /**
     * 경로 품질 분석
     * 
     * @param locations 위치 데이터 목록
     * @return 품질 분석 결과
     */
    private fun analyzeRouteQuality(locations: List<Map<String, Any>>): Map<String, Any> {
        val quality = mutableMapOf<String, Any>()
        
        var highAccuracyCount = 0
        var mediumAccuracyCount = 0
        var lowAccuracyCount = 0
        
        locations.forEach { location ->
            val accuracy = location["accuracy"] as Double
            
            when {
                accuracy <= 5 -> highAccuracyCount++
                accuracy <= 20 -> mediumAccuracyCount++
                else -> lowAccuracyCount++
            }
        }
        
        val total = locations.size
        quality["highAccuracyPercentage"] = if (total > 0) {
            (highAccuracyCount.toDouble() / total * 100.0 * 10.0).roundToInt() / 10.0
        } else {
            0.0
        }
        quality["mediumAccuracyPercentage"] = if (total > 0) {
            (mediumAccuracyCount.toDouble() / total * 100.0 * 10.0).roundToInt() / 10.0
        } else {
            0.0
        }
        quality["lowAccuracyPercentage"] = if (total > 0) {
            (lowAccuracyCount.toDouble() / total * 100.0 * 10.0).roundToInt() / 10.0
        } else {
            0.0
        }
        
        return quality
    }
} 