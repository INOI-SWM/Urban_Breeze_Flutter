import '../models/workout_statistics_response_model.dart';

// TODO: 추후 실제 API 호출로 교체
class WorkoutStatisticsDatasource {
  /// 기간별 운동 통계 데이터 조회
  Future<WorkoutStatisticsResponseModel> getWorkoutStatistics({
    required String periodType, // "week", "month", "year", "all"
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // TODO: 실제 API 호출 구현

    final Map<String, dynamic> jsonData = _getMockStatisticsData(periodType);
    return WorkoutStatisticsResponseModel.fromJson(jsonData);
  }

  /// Mock 데이터 생성 (실제 API 응답 형식에 맞춤)
  Map<String, dynamic> _getMockStatisticsData(String periodType) {
    switch (periodType) {
      case 'week':
        return <String, dynamic>{
          'period': <String, String>{
            'type': 'week',
            'startDate': '2025-06-29',
            'endDate': '2025-07-05',
            'displayTitle': '25년 7월 3주',
          },
          'summary': <String, num>{
            'totalDistance': 84.5, // km
            'totalElevationGain': 980, // m
            'totalDuration': 10860, // 초 (3시간 1분)
            'totalActivityCount': 3, // 횟수
          },
          'details': <Map<String, Object>>[
            <String, Object>{
              'label': '29',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '30',
              'value': <String, num>{
                'distanceKm': 25.2,
                'elevationGainM': 320,
                'durationSec': 3600,
              },
            },
            <String, Object>{
              'label': '1',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '2',
              'value': <String, num>{
                'distanceKm': 30.1,
                'elevationGainM': 410,
                'durationSec': 4200,
              },
            },
            <String, Object>{
              'label': '3',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '4',
              'value': <String, num>{
                'distanceKm': 29.2,
                'elevationGainM': 250,
                'durationSec': 3060,
              },
            },
            <String, Object>{
              'label': '5',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
          ],
        };
      case 'month':
        return <String, dynamic>{
          'period': <String, String>{
            'type': 'month',
            'startDate': '2025-07-01',
            'endDate': '2025-07-31',
            'displayTitle': '25년 7월',
          },
          'summary': <String, num>{
            'totalDistance': 325.8,
            'totalElevationGain': 2450,
            'totalDuration': 45720, // 12시간 42분
            'totalActivityCount': 12,
          },
          'details': <dynamic>[], // 월별 상세 데이터는 나중에 구현
        };
      case 'year':
        return <String, dynamic>{
          'period': <String, String>{
            'type': 'year',
            'startDate': '2025-01-01',
            'endDate': '2025-12-31',
            'displayTitle': '2025년',
          },
          'summary': <String, num>{
            'totalDistance': 1689.3,
            'totalElevationGain': 15680,
            'totalDuration': 185400, // 51시간 30분
            'totalActivityCount': 28,
          },
          'details': <dynamic>[], // 년별 상세 데이터는 나중에 구현
        };
      case 'all':
        return <String, dynamic>{
          'period': <String, String>{
            'type': 'all',
            'startDate': '2024-01-01',
            'endDate': '2025-12-31',
            'displayTitle': '전체',
          },
          'summary': <String, num>{
            'totalDistance': 2456.7,
            'totalElevationGain': 18900,
            'totalDuration': 295200, // 82시간
            'totalActivityCount': 48,
          },
          'details': <dynamic>[], // 전체 상세 데이터는 나중에 구현
        };
      default:
        throw ArgumentError('지원하지 않는 기간 타입: $periodType');
    }
  }
}
