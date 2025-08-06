package com.inoi.ridingmate.dev.healthconnect.providers

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.HeartRateRecord
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
import java.util.concurrent.TimeUnit

/**
 * 심박수 데이터 전용 프로바이더
 * 
 * Health Connect에서 심박수(HeartRateRecord) 데이터만을 전담하여 처리
 */
class HeartRateDataProvider(
    private val context: Context,
    private val healthConnectManager: HealthConnectManager
) {
    private val TAG = "HeartRateDataProvider"
    private val coroutineScope = healthConnectManager.getCoroutineScope()



    /**
     * 심박수 데이터 조회
     * 
     * @param startTime 시작 시간 (밀리초)
     * @param endTime 종료 시간 (밀리초)
     * @param result Flutter 결과 콜백
     */
    fun getHeartRateData(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                val data = fetchHeartRateDataFromHealthConnect(startTime, endTime)
                result.success(data)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error fetching heart rate data: ${e.message}")
                result.error("HEART_RATE_DATA_ERROR", e.message, null)
            }
        }
    }

    /**
     * Health Connect에서 실제 심박수 데이터 조회
     * 
     * @param startTime 시작 시간
     * @param endTime 종료 시간
     * @return 심박수 데이터 목록
     */
    private suspend fun fetchHeartRateDataFromHealthConnect(startTime: Long, endTime: Long): List<Map<String, Any>> {
        return withContext(Dispatchers.IO) {
            val heartRateData = mutableListOf<Map<String, Any>>()
            
            try {
                val client = healthConnectManager.getClient()
                
                if (client == null) {
                    android.util.Log.w(TAG, "Health Connect client not available")
                    return@withContext heartRateData
                }


                
                // 시간 범위 필터 생성
                val timeFilter = TimeRangeFilter.between(
                    Instant.ofEpochMilli(startTime),
                    Instant.ofEpochMilli(endTime)
                )
                
                // 심박수 데이터 조회 요청
                val request = ReadRecordsRequest(
                    recordType = HeartRateRecord::class,
                    timeRangeFilter = timeFilter
                )
                
                // 데이터 조회 실행 (Kotlin suspend 함수 사용)
                val response: ReadRecordsResponse<HeartRateRecord> = client.readRecords(request)
                val records = response.records
                

                
                // 각 레코드를 Flutter 형식으로 변환
                records.forEach { record ->
                    record.samples.forEach { sample ->
                        val heartRateMap = convertHeartRateToMap(sample, record)
                        heartRateData.add(heartRateMap)
                    }
                }
                
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error in fetchHeartRateDataFromHealthConnect: ${e.message}")
                // 에러 발생 시 빈 리스트 반환
            }
            
            heartRateData
        }
    }

    /**
     * HeartRateRecord Sample을 Map으로 변환
     * 
     * @param sample 심박수 샘플
     * @param record 심박수 레코드
     * @return Flutter에서 사용할 Map 형태 데이터
     */
    private fun convertHeartRateToMap(sample: HeartRateRecord.Sample, record: HeartRateRecord): Map<String, Any> {
        return mapOf(
            "timestamp" to sample.time.toEpochMilli(),
            "heartRate" to sample.beatsPerMinute.toInt(),
            "reliability" to "HIGH", // Health Connect에서 제공하는 데이터는 일반적으로 신뢰도가 높음
            "source" to record.metadata.dataOrigin.packageName // 데이터 소스
        )
    }

    /**
     * 심박수 통계 정보 계산
     * 
     * @param startTime 시작 시간
     * @param endTime 종료 시간
     * @param result Flutter 결과 콜백
     */
    fun getHeartRateStatistics(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        
        coroutineScope.launch {
            try {
                val heartRateData = fetchHeartRateDataFromHealthConnect(startTime, endTime)
                val stats = calculateHeartRateStatistics(heartRateData)
                result.success(stats)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error calculating heart rate statistics: ${e.message}")
                result.error("HEART_RATE_STATS_ERROR", e.message, null)
            }
        }
    }

    /**
     * 심박수 통계 계산
     * 
     * @param heartRateData 심박수 데이터 목록
     * @return 심박수 통계 정보
     */
    private fun calculateHeartRateStatistics(heartRateData: List<Map<String, Any>>): Map<String, Any> {
        val statistics = mutableMapOf<String, Any>()
        
        if (heartRateData.isEmpty()) {
            statistics["count"] = 0
            statistics["average"] = 0
            statistics["minimum"] = 0
            statistics["maximum"] = 0
            return statistics
        }
        
        var sum = 0
        var min = Int.MAX_VALUE
        var max = Int.MIN_VALUE
        
        heartRateData.forEach { record ->
            val heartRate = record["heartRate"] as Int
            sum += heartRate
            min = minOf(min, heartRate)
            max = maxOf(max, heartRate)
        }
        
        val count = heartRateData.size
        val average = sum.toDouble() / count
        
        statistics["count"] = count
        statistics["average"] = (average * 10).toInt() / 10.0 // 소수점 1자리
        statistics["minimum"] = min
        statistics["maximum"] = max
        statistics["total"] = sum
        
        // 심박수 구간 분석
        val zones = calculateHeartRateZones(heartRateData)
        statistics["zones"] = zones
        
        return statistics
    }

    /**
     * 심박수 구간별 분석 (심박수 존)
     * 
     * @param heartRateData 심박수 데이터
     * @return 구간별 데이터 개수
     */
    private fun calculateHeartRateZones(heartRateData: List<Map<String, Any>>): Map<String, Int> {
        val zones = mutableMapOf(
            "rest" to 0,        // < 100 bpm
            "light" to 0,       // 100-130 bpm
            "moderate" to 0,    // 130-150 bpm
            "vigorous" to 0,    // 150-170 bpm
            "maximum" to 0      // > 170 bpm
        )
        
        heartRateData.forEach { record ->
            val heartRate = record["heartRate"] as Int
            
            when {
                heartRate < 100 -> zones["rest"] = zones["rest"]!! + 1
                heartRate < 130 -> zones["light"] = zones["light"]!! + 1
                heartRate < 150 -> zones["moderate"] = zones["moderate"]!! + 1
                heartRate < 170 -> zones["vigorous"] = zones["vigorous"]!! + 1
                else -> zones["maximum"] = zones["maximum"]!! + 1
            }
        }
        
        return zones
    }

    /**
     * 심박수 데이터 품질 검증
     * 
     * @param heartRate 심박수 값
     * @return 유효성 여부
     */
    private fun isValidHeartRate(heartRate: Int): Boolean {
        // 일반적인 인간의 심박수 범위: 30-220 bpm
        return heartRate in 30..220
    }
} 