package com.inoi.ridingmate.dev.healthconnect.providers

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.ExerciseSessionRecord
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
 * 운동 세션 데이터 전용 프로바이더
 * 
 * Health Connect에서 운동 세션(ExerciseSessionRecord) 데이터만을 전담하여 처리
 * 자전거 운동에 특화된 로직 포함
 */
class ExerciseDataProvider(
    private val context: Context,
    private val healthConnectManager: HealthConnectManager
) {
    private val TAG = "ExerciseDataProvider"
    private val coroutineScope = healthConnectManager.getCoroutineScope()

    /**
     * 운동 세션 데이터 조회
     * 
     * @param startTime 시작 시간 (밀리초)
     * @param endTime 종료 시간 (밀리초)
     * @param result Flutter 결과 콜백
     */
    fun getExerciseSessions(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        android.util.Log.d(TAG, "Getting exercise sessions from $startTime to $endTime")
        
        coroutineScope.launch {
            try {
                val data = fetchExerciseSessionsFromHealthConnect(startTime, endTime)
                result.success(data)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error fetching exercise sessions: ${e.message}")
                result.error("EXERCISE_DATA_ERROR", e.message, null)
            }
        }
    }

    /**
     * Health Connect에서 실제 운동 세션 데이터 조회
     * 
     * @param startTime 시작 시간
     * @param endTime 종료 시간
     * @return 운동 세션 데이터 목록
     */
    suspend fun fetchExerciseSessionsFromHealthConnect(startTime: Long, endTime: Long): List<Map<String, Any?>> {
        return withContext(Dispatchers.IO) {
            val exerciseSessions = mutableListOf<Map<String, Any?>>()
            
            try {
                val client = healthConnectManager.getClient()
                
                if (client == null) {
                    android.util.Log.w(TAG, "Health Connect client not available")
                    return@withContext exerciseSessions
                }

                // Health Connect 1.1.0-alpha12 실제 API 호출
                android.util.Log.d(TAG, "Fetching exercise sessions from Health Connect")
                
                // 시간 범위 필터 생성
                val timeFilter = TimeRangeFilter.between(
                    Instant.ofEpochMilli(startTime),
                    Instant.ofEpochMilli(endTime)
                )
                
                // 운동 세션 데이터 조회 요청
                val request = ReadRecordsRequest(
                    recordType = ExerciseSessionRecord::class,
                    timeRangeFilter = timeFilter
                )
                
                // 데이터 조회 실행 (Kotlin suspend 함수 사용)
                val response: ReadRecordsResponse<ExerciseSessionRecord> = client.readRecords(request)
                val records = response.records
                
                android.util.Log.d(TAG, "Found ${records.size} exercise session records, filtering cycling types")
                
                // 각 레코드를 Flutter 형식으로 변환 (자전거 타입만 필터링)
                records.forEachIndexed { index, record ->
                    try {
                        // 자전거 타입만 필터링 (8: BIKING, 9: BIKING_STATIONARY)
                        if (record.exerciseType == 8 || record.exerciseType == 9) {
                            val sessionMap = convertExerciseSessionToMap(record)
                            exerciseSessions.add(sessionMap)
                        }
                    } catch (e: Exception) {
                        android.util.Log.e(TAG, "Error converting record $index: ${e.message}")
                    }
                }
                
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error in fetchExerciseSessionsFromHealthConnect: ${e.message}")
                // 에러 발생 시 빈 리스트 반환
            }
            
            exerciseSessions
        }
    }

    /**
     * ExerciseSessionRecord를 Map으로 변환
     * 
     * @param record 운동 세션 레코드
     * @return Flutter에서 사용할 Map 형태 데이터
     */
        private fun convertExerciseSessionToMap(record: ExerciseSessionRecord): Map<String, Any?> {
        return mapOf(
            "id" to record.metadata.id,
            "startTime" to record.startTime.toEpochMilli(),
            "endTime" to record.endTime.toEpochMilli(),
            "exerciseType" to record.exerciseType,
            "title" to (record.title ?: ""),
            "notes" to (record.notes ?: ""),
            "sessionId" to record.metadata.id
        )
    }


} 