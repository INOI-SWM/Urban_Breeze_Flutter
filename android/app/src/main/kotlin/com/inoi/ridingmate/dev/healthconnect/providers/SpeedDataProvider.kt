package com.inoi.ridingmate.dev.healthconnect.providers

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.SpeedRecord
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
 * 속도 데이터 전용 프로바이더
 * 
 * Health Connect에서 속도(SpeedRecord) 데이터만을 전담하여 처리
 */
class SpeedDataProvider(
    private val context: Context,
    private val healthConnectManager: HealthConnectManager
) {
    private val TAG = "SpeedDataProvider"
    private val coroutineScope = healthConnectManager.getCoroutineScope()

    init {
        android.util.Log.d(TAG, "SpeedDataProvider initialized")
    }

    /**
     * 속도 데이터 조회
     * 
     * @param startTime 시작 시간 (밀리초)
     * @param endTime 종료 시간 (밀리초)
     * @param result Flutter 결과 콜백
     */
    fun getSpeedData(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        android.util.Log.d(TAG, "Getting speed data from $startTime to $endTime")
        
        coroutineScope.launch {
            try {
                val data = fetchSpeedDataFromHealthConnect(startTime, endTime)
                result.success(data)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error fetching speed data: ${e.message}")
                result.error("SPEED_DATA_ERROR", e.message, null)
            }
        }
    }

    /**
     * Health Connect에서 실제 속도 데이터 조회
     * 
     * @param startTime 시작 시간
     * @param endTime 종료 시간
     * @return 속도 데이터 목록
     */
    suspend fun fetchSpeedDataFromHealthConnect(startTime: Long, endTime: Long): List<Map<String, Any>> {
        return withContext(Dispatchers.IO) {
            val speedData = mutableListOf<Map<String, Any>>()
            
            try {
                val client = healthConnectManager.getClient()
                
                if (client == null) {
                    android.util.Log.w(TAG, "Health Connect client not available")
                    return@withContext speedData
                }

                // Health Connect 1.1.0-alpha12 실제 API 호출
                android.util.Log.d(TAG, "Fetching speed data from Health Connect")
                
                // 시간 범위 필터 생성
                val timeFilter = TimeRangeFilter.between(
                    Instant.ofEpochMilli(startTime),
                    Instant.ofEpochMilli(endTime)
                )
                
                // 속도 데이터 조회 요청
                val request = ReadRecordsRequest(
                    recordType = SpeedRecord::class,
                    timeRangeFilter = timeFilter
                )
                
                // 데이터 조회 실행 (Kotlin suspend 함수 사용)
                val response: ReadRecordsResponse<SpeedRecord> = client.readRecords(request)
                val records = response.records
                
                android.util.Log.d(TAG, "Found ${records.size} speed records")
                
                // 각 레코드를 Flutter 형식으로 변환
                records.forEach { record ->
                    record.samples.forEach { sample ->
                        val speedMap = convertSpeedToMap(sample, record)
                        speedData.add(speedMap)
                    }
                }
                
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error in fetchSpeedDataFromHealthConnect: ${e.message}")
                // 에러 발생 시 빈 리스트 반환
            }
            
            speedData
        }
    }

    /**
     * SpeedRecord Sample을 Map으로 변환
     * 
     * @param sample 속도 샘플
     * @param record 속도 레코드
     * @return Flutter에서 사용할 Map 형태 데이터
     */
    private fun convertSpeedToMap(sample: SpeedRecord.Sample, record: SpeedRecord): Map<String, Any> {
        val speedMps = sample.speed.inMetersPerSecond
        val speedKmh = speedMps * 3.6
        
        return mapOf(
            "timestamp" to sample.time.toEpochMilli(),
            "speed" to (speedKmh * 100).toInt() / 100.0, // km/h, 소수점 2자리
            "speedMps" to (speedMps * 100).toInt() / 100.0, // m/s 단위도 제공
            "source" to record.metadata.dataOrigin.packageName, // 데이터 소스
            "accuracy" to "HIGH" // Health Connect에서 제공하는 데이터는 일반적으로 정확도가 높음
        )
    }

    /**
     * 속도 통계 정보 계산
     * 
     * @param startTime 시작 시간
     * @param endTime 종료 시간
     * @param result Flutter 결과 콜백
     */
    fun getSpeedStatistics(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        android.util.Log.d(TAG, "Getting speed statistics")
        
        coroutineScope.launch {
            try {
                val speedData = fetchSpeedDataFromHealthConnect(startTime, endTime)
                val stats = calculateSpeedStatistics(speedData)
                result.success(stats)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error calculating speed statistics: ${e.message}")
                result.error("SPEED_STATS_ERROR", e.message, null)
            }
        }
    }

    /**
     * 속도 통계 계산
     * 
     * @param speedData 속도 데이터 목록
     * @return 속도 통계 정보
     */
    private fun calculateSpeedStatistics(speedData: List<Map<String, Any>>): Map<String, Any> {
        val statistics = mutableMapOf<String, Any>()
        
        if (speedData.isEmpty()) {
            statistics["count"] = 0
            statistics["average"] = 0.0
            statistics["minimum"] = 0.0
            statistics["maximum"] = 0.0
            return statistics
        }
        
        var sum = 0.0
        var min = Double.MAX_VALUE
        var max = Double.MIN_VALUE
        
        speedData.forEach { record ->
            val speed = record["speed"] as Double
            sum += speed
            min = minOf(min, speed)
            max = maxOf(max, speed)
        }
        
        val count = speedData.size
        val average = sum / count
        
        statistics["count"] = count
        statistics["average"] = (average * 100).toInt() / 100.0 // km/h, 소수점 2자리
        statistics["minimum"] = (min * 100).toInt() / 100.0
        statistics["maximum"] = (max * 100).toInt() / 100.0
        
        // 속도 구간 분석
        val zones = calculateSpeedZones(speedData)
        statistics["zones"] = zones
        
        // 이동 시간 vs 정지 시간 분석
        val movementAnalysis = analyzeMovement(speedData)
        statistics["movement"] = movementAnalysis
        
        android.util.Log.d(TAG, "Speed statistics: avg=$average, min=$min, max=$max, count=$count")
        
        return statistics
    }

    /**
     * 속도 구간별 분석
     * 
     * @param speedData 속도 데이터
     * @return 구간별 데이터 개수
     */
    private fun calculateSpeedZones(speedData: List<Map<String, Any>>): Map<String, Int> {
        val zones = mutableMapOf(
            "stopped" to 0,      // 0-2 km/h
            "walking" to 0,      // 2-8 km/h
            "jogging" to 0,      // 8-15 km/h
            "cycling" to 0,      // 15-30 km/h
            "fast" to 0          // > 30 km/h
        )
        
        speedData.forEach { record ->
            val speed = record["speed"] as Double
            
            when {
                speed < 2 -> zones["stopped"] = zones["stopped"]!! + 1
                speed < 8 -> zones["walking"] = zones["walking"]!! + 1
                speed < 15 -> zones["jogging"] = zones["jogging"]!! + 1
                speed < 30 -> zones["cycling"] = zones["cycling"]!! + 1
                else -> zones["fast"] = zones["fast"]!! + 1
            }
        }
        
        return zones
    }

    /**
     * 이동/정지 시간 분석
     * 
     * @param speedData 속도 데이터
     * @return 이동 분석 결과
     */
    private fun analyzeMovement(speedData: List<Map<String, Any>>): Map<String, Any> {
        val movement = mutableMapOf<String, Any>()
        
        var movingCount = 0
        var stoppedCount = 0
        var movingSpeedSum = 0.0
        
        val MOVEMENT_THRESHOLD = 2.0 // 2 km/h 이상을 이동으로 간주
        
        speedData.forEach { record ->
            val speed = record["speed"] as Double
            
            if (speed >= MOVEMENT_THRESHOLD) {
                movingCount++
                movingSpeedSum += speed
            } else {
                stoppedCount++
            }
        }
        
        movement["movingCount"] = movingCount
        movement["stoppedCount"] = stoppedCount
        movement["movingPercentage"] = (movingCount.toDouble() / speedData.size * 100.0 * 10.0).toInt() / 10.0
        movement["averageMovingSpeed"] = if (movingCount > 0) {
            (movingSpeedSum / movingCount * 100.0).toInt() / 100.0
        } else {
            0.0
        }
        
        return movement
    }

    /**
     * 속도 데이터 품질 검증
     * 
     * @param speed 속도 값 (km/h)
     * @return 유효성 여부
     */
    private fun isValidSpeed(speed: Double): Boolean {
        // 일반적인 속도 범위: 0-100 km/h (자전거 기준)
        return speed in 0.0..100.0
    }
} 