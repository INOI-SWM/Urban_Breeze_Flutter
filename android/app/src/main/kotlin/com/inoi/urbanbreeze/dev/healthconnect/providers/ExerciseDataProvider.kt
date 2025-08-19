package com.inoi.urbanbreeze.dev.healthconnect.providers

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.health.connect.client.records.TotalCaloriesBurnedRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.response.ReadRecordsResponse
import androidx.health.connect.client.time.TimeRangeFilter
import com.inoi.urbanbreeze.dev.healthconnect.HealthConnectManager
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.time.Instant

class ExerciseDataProvider(
    private val context: Context,
    private val healthConnectManager: HealthConnectManager
) {
    private val TAG = "ExerciseDataProvider"
    private val coroutineScope = healthConnectManager.getCoroutineScope()

    fun getExerciseSessions(startTime: Long, endTime: Long, result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                val data = fetchExerciseSessionsFromHealthConnect(startTime, endTime)
                result.success(data)
            } catch (e: Exception) {
                result.error("EXERCISE_DATA_ERROR", e.message, null)
            }
        }
    }

    suspend fun fetchExerciseSessionsFromHealthConnect(startTime: Long, endTime: Long): List<Map<String, Any?>> {
        return withContext(Dispatchers.IO) {
            val exerciseSessions = mutableListOf<Map<String, Any?>>()
            val client = healthConnectManager.getClient() ?: return@withContext exerciseSessions

            val timeFilter = TimeRangeFilter.between(
                Instant.ofEpochMilli(startTime),
                Instant.ofEpochMilli(endTime)
            )

            val request = ReadRecordsRequest(
                recordType = ExerciseSessionRecord::class,
                timeRangeFilter = timeFilter
            )

            val response: ReadRecordsResponse<ExerciseSessionRecord> = client.readRecords(request)
            val records = response.records

            for (record in records) {
                try {
                    //8 : 실외자전거
                    if (record.exerciseType == 8 ) {
                        // 🔥 칼로리 데이터 가져오기
                        val calories = fetchCaloriesForSession(client, record.startTime.toEpochMilli(), record.endTime.toEpochMilli())

                        val sessionMap = convertExerciseSessionToMap(record, calories)
                        exerciseSessions.add(sessionMap)
                    }
                } catch (_: Exception) { }
            }

            exerciseSessions
        }
    }

    /**
     * 🧠 운동 세션 시간에 해당하는 칼로리 데이터 조회
     */
    private suspend fun fetchCaloriesForSession(
        client: HealthConnectClient,
        startTimeMillis: Long,
        endTimeMillis: Long
    ): Double {
        val timeFilter = TimeRangeFilter.between(
            Instant.ofEpochMilli(startTimeMillis),
            Instant.ofEpochMilli(endTimeMillis)
        )

        val request = ReadRecordsRequest(
            recordType = TotalCaloriesBurnedRecord::class,
            timeRangeFilter = timeFilter
        )

        return try {
            val response = client.readRecords(request)
            response.records.sumOf { it.energy.inKilocalories }
        } catch (e: Exception) {
            0.0
        }
    }

    /**
     * 🧱 운동 세션 + 칼로리 포함된 Map 생성
     */
    private fun convertExerciseSessionToMap(record: ExerciseSessionRecord, calories: Double): Map<String, Any?> {
        return mapOf(
            "id" to record.metadata.id,
            "startTime" to record.startTime.toEpochMilli(),
            "endTime" to record.endTime.toEpochMilli(),
            "exerciseType" to record.exerciseType,
            "title" to (record.title ?: ""),
            "notes" to (record.notes ?: ""),
            "sessionId" to record.metadata.id,
            "calories" to calories // 👈 추가된 칼로리 값
        )
    }
}
