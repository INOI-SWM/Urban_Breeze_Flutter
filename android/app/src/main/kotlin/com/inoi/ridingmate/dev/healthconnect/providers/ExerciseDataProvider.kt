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

    init {
        android.util.Log.d(TAG, "ExerciseDataProvider initialized")
    }

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
                
                android.util.Log.d(TAG, "Found ${records.size} exercise session records")
                
                // 각 레코드를 Flutter 형식으로 변환
                records.forEach { record ->
                    val sessionMap = convertExerciseSessionToMap(record)
                    exerciseSessions.add(sessionMap)
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
            "endTime" to record.endTime?.toEpochMilli(),
            "exerciseType" to record.exerciseType.toString(),
            "title" to (record.title ?: ""),
            "notes" to (record.notes ?: ""),
            "sessionId" to record.metadata.id
        )
    }

    /**
     * 특정 운동 세션의 상세 데이터 조회 (경로 포함)
     * 
     * @param sessionId 운동 세션 ID
     * @param result Flutter 결과 콜백
     */
    fun getExerciseSessionDetail(sessionId: String, result: MethodChannel.Result) {
        android.util.Log.d(TAG, "Getting exercise session detail for: $sessionId")
        
        coroutineScope.launch {
            try {
                val detail = fetchExerciseSessionDetail(sessionId)
                result.success(detail)
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error fetching exercise session detail: ${e.message}")
                result.error("EXERCISE_DETAIL_ERROR", e.message, null)
            }
        }
    }

    /**
     * 운동 세션 상세 데이터 조회 (실제 구현)
     * 
     * @param sessionId 세션 ID
     * @return 상세 운동 데이터
     */
    private suspend fun fetchExerciseSessionDetail(sessionId: String): Map<String, Any> {
        return withContext(Dispatchers.IO) {
            val detail = mutableMapOf<String, Any>()
            
            try {
                val client = healthConnectManager.getClient()
                
                if (client == null) {
                    throw RuntimeException("Health Connect client not available")
                }

                // TODO: Health Connect 1.1.0-alpha12에서 운동 경로 조회
                // 현재는 기본 정보만 반환
                detail["id"] = sessionId
                detail["status"] = "Health Connect API integration pending"
                
                android.util.Log.d(TAG, "Exercise session detail API integration pending")
                
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error fetching exercise session detail: ${e.message}")
                throw RuntimeException("Failed to fetch exercise session detail", e)
            }
            
            detail
        }
    }

    /**
     * 운동 타입별 필터링 (향후 확장용)
     * 
     * @param exerciseType 운동 타입
     * @return 지원 여부
     */
    fun isSupportedExerciseType(exerciseType: String): Boolean {
        // 현재는 자전거 운동만 지원
        return exerciseType.equals("CYCLING", ignoreCase = true) || 
               exerciseType.equals("BIKING", ignoreCase = true)
    }
} 