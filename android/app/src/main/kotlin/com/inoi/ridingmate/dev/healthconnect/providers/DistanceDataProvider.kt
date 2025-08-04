package com.inoi.ridingmate.dev.healthconnect.providers

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.DistanceRecord
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

/**
 * 거리 데이터 전용 프로바이더
 * 
 * Health Connect에서 거리(DistanceRecord) 데이터만을 전담하여 처리
 */
class DistanceDataProvider(
    private val context: Context,
    private val healthConnectManager: HealthConnectManager
) {
    private val TAG = "DistanceDataProvider"
    private val coroutineScope = healthConnectManager.getCoroutineScope()

    init {
        android.util.Log.d(TAG, "DistanceDataProvider initialized")
    }

    /**
     * 거리 데이터 조회
     * 
     * @param startTime 시작 시간 (밀리초)
     * @param endTime 종료 시간 (밀리초)
     * @param result Flutter 결과 콜백
     */
    fun getDistanceData(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        android.util.Log.d(TAG, "Getting distance data from $startTime to $endTime")
        
        coroutineScope.launch {
            try {
                val data = fetchDistanceDataFromHealthConnect(startTime, endTime)
                result.success(data)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error fetching distance data: ${e.message}")
                result.error("DISTANCE_DATA_ERROR", e.message, null)
            }
        }
    }

    /**
     * Health Connect에서 실제 거리 데이터 조회
     * 
     * @param startTime 시작 시간
     * @param endTime 종료 시간
     * @return 거리 데이터 목록
     */
    suspend fun fetchDistanceDataFromHealthConnect(startTime: Long, endTime: Long): List<Map<String, Any>> {
        return withContext(Dispatchers.IO) {
            val distanceData = mutableListOf<Map<String, Any>>()
            
            try {
                val client = healthConnectManager.getClient()
                
                if (client == null) {
                    android.util.Log.w(TAG, "Health Connect client not available")
                    return@withContext distanceData
                }

                // Health Connect 1.1.0-alpha12 실제 API 호출
                android.util.Log.d(TAG, "Fetching distance data from Health Connect")
                
                // 시간 범위 필터 생성
                val timeFilter = TimeRangeFilter.between(
                    Instant.ofEpochMilli(startTime),
                    Instant.ofEpochMilli(endTime)
                )
                
                // 거리 데이터 조회 요청
                val request = ReadRecordsRequest(
                    recordType = DistanceRecord::class,
                    timeRangeFilter = timeFilter
                )
                
                // 데이터 조회 실행 (Kotlin suspend 함수 사용)
                val response: ReadRecordsResponse<DistanceRecord> = client.readRecords(request)
                val records = response.records
                
                android.util.Log.d(TAG, "Found ${records.size} distance records")
                
                // 각 레코드를 Flutter 형식으로 변환
                records.forEach { record ->
                    val distanceMap = convertDistanceToMap(record)
                    distanceData.add(distanceMap)
                }
                
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error in fetchDistanceDataFromHealthConnect: ${e.message}")
                // 에러 발생 시 빈 리스트 반환
            }
            
            distanceData
        }
    }

    /**
     * DistanceRecord를 Map으로 변환
     * 
     * @param record 거리 레코드
     * @return Flutter에서 사용할 Map 형태 데이터
     */
    private fun convertDistanceToMap(record: DistanceRecord): Map<String, Any> {
        val distanceMeters = record.distance.inMeters
        val distanceKm = distanceMeters / 1000.0
        
        return mapOf(
            "timestamp" to record.startTime.toEpochMilli(),
            "distance" to (distanceKm * 100).toInt() / 100.0, // km, 소수점 2자리
            "distanceMeters" to distanceMeters, // 미터 단위도 제공
            "startTime" to record.startTime.toEpochMilli(),
            "endTime" to record.endTime.toEpochMilli(),
            "duration" to (record.endTime.toEpochMilli() - record.startTime.toEpochMilli()),
            "source" to record.metadata.dataOrigin.packageName, // 데이터 소스
            "accuracy" to "HIGH" // Health Connect에서 제공하는 데이터는 일반적으로 정확도가 높음
        )
    }

    /**
     * 거리 통계 정보 계산
     * 
     * @param startTime 시작 시간
     * @param endTime 종료 시간
     * @param result Flutter 결과 콜백
     */
    fun getDistanceStatistics(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        android.util.Log.d(TAG, "Getting distance statistics")
        
        coroutineScope.launch {
            try {
                val distanceData = fetchDistanceDataFromHealthConnect(startTime, endTime)
                val stats = calculateDistanceStatistics(distanceData)
                result.success(stats)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error calculating distance statistics: ${e.message}")
                result.error("DISTANCE_STATS_ERROR", e.message, null)
            }
        }
    }

    /**
     * 거리 통계 계산
     * 
     * @param distanceData 거리 데이터 목록
     * @return 거리 통계 정보
     */
    private fun calculateDistanceStatistics(distanceData: List<Map<String, Any>>): Map<String, Any> {
        val statistics = mutableMapOf<String, Any>()
        
        if (distanceData.isEmpty()) {
            statistics["totalDistance"] = 0.0
            statistics["averageDistance"] = 0.0
            statistics["count"] = 0
            statistics["totalDuration"] = 0L
            return statistics
        }
        
        var totalDistance = 0.0
        var totalDuration = 0L
        var maxDistance = 0.0
        var minDistance = Double.MAX_VALUE
        
        distanceData.forEach { record ->
            val distance = record["distance"] as Double
            val duration = record["duration"] as Long
            
            totalDistance += distance
            totalDuration += duration
            maxDistance = maxOf(maxDistance, distance)
            minDistance = minOf(minDistance, distance)
        }
        
        val count = distanceData.size
        val averageDistance = totalDistance / count
        
        statistics["totalDistance"] = (totalDistance * 100).toInt() / 100.0 // km, 소수점 2자리
        statistics["averageDistance"] = (averageDistance * 100).toInt() / 100.0
        statistics["maximumDistance"] = (maxDistance * 100).toInt() / 100.0
        statistics["minimumDistance"] = (minDistance * 100).toInt() / 100.0
        statistics["count"] = count
        statistics["totalDuration"] = totalDuration // 밀리초
        
        // 평균 속도 계산 (km/h)
        val totalHours = totalDuration / (1000.0 * 60 * 60)
        val averageSpeed = if (totalHours > 0) {
            (totalDistance / totalHours * 100).toInt() / 100.0
        } else {
            0.0
        }
        statistics["averageSpeed"] = averageSpeed
        
        // 거리 구간 분석
        val zones = calculateDistanceZones(distanceData)
        statistics["zones"] = zones
        
        android.util.Log.d(TAG, "Distance statistics: total=$totalDistance, avg=$averageDistance, count=$count")
        
        return statistics
    }

    /**
     * 거리 구간별 분석
     * 
     * @param distanceData 거리 데이터
     * @return 구간별 데이터 개수
     */
    private fun calculateDistanceZones(distanceData: List<Map<String, Any>>): Map<String, Int> {
        val zones = mutableMapOf(
            "short" to 0,        // < 5 km
            "medium" to 0,       // 5-20 km
            "long" to 0,         // 20-50 km
            "veryLong" to 0      // > 50 km
        )
        
        distanceData.forEach { record ->
            val distance = record["distance"] as Double
            
            when {
                distance < 5 -> zones["short"] = zones["short"]!! + 1
                distance < 20 -> zones["medium"] = zones["medium"]!! + 1
                distance < 50 -> zones["long"] = zones["long"]!! + 1
                else -> zones["veryLong"] = zones["veryLong"]!! + 1
            }
        }
        
        return zones
    }

    /**
     * 거리 데이터 품질 검증
     * 
     * @param distance 거리 값 (km)
     * @return 유효성 여부
     */
    private fun isValidDistance(distance: Double): Boolean {
        // 일반적인 거리 범위: 0-200 km (자전거 기준)
        return distance in 0.0..200.0
    }
} 