import '../../domain/enums/statistic_enums.dart';

/// 운동 통계 Mock 데이터 클래스
/// TODO: 실제 API 연동 시 삭제 예정
class MockWorkoutStatisticsData {
  MockWorkoutStatisticsData._();

  /// Mock 데이터 생성 (실제 API 응답 형식에 맞춤)
  static Map<String, dynamic> getMockStatisticsData(
    StatisticPeriodType periodType,
  ) {
    switch (periodType) {
      case StatisticPeriodType.week:
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
      case StatisticPeriodType.month:
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
          'details': <Map<String, Object>>[
            // 7월 1일부터 31일까지
            <String, Object>{
              'label': '1',
              'value': <String, num>{
                'distanceKm': 15.2,
                'elevationGainM': 120,
                'durationSec': 2400,
              },
            },
            <String, Object>{
              'label': '2',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '3',
              'value': <String, num>{
                'distanceKm': 22.1,
                'elevationGainM': 280,
                'durationSec': 3200,
              },
            },
            <String, Object>{
              'label': '4',
              'value': <String, num>{
                'distanceKm': 18.5,
                'elevationGainM': 150,
                'durationSec': 2800,
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
            <String, Object>{
              'label': '6',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '7',
              'value': <String, num>{
                'distanceKm': 28.3,
                'elevationGainM': 320,
                'durationSec': 4100,
              },
            },
            <String, Object>{
              'label': '8',
              'value': <String, num>{
                'distanceKm': 12.7,
                'elevationGainM': 90,
                'durationSec': 1900,
              },
            },
            <String, Object>{
              'label': '9',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '10',
              'value': <String, num>{
                'distanceKm': 25.6,
                'elevationGainM': 200,
                'durationSec': 3600,
              },
            },
            <String, Object>{
              'label': '11',
              'value': <String, num>{
                'distanceKm': 19.2,
                'elevationGainM': 170,
                'durationSec': 2900,
              },
            },
            <String, Object>{
              'label': '12',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '13',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '14',
              'value': <String, num>{
                'distanceKm': 31.4,
                'elevationGainM': 410,
                'durationSec': 4800,
              },
            },
            <String, Object>{
              'label': '15',
              'value': <String, num>{
                'distanceKm': 16.8,
                'elevationGainM': 130,
                'durationSec': 2600,
              },
            },
            <String, Object>{
              'label': '16',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '17',
              'value': <String, num>{
                'distanceKm': 24.9,
                'elevationGainM': 290,
                'durationSec': 3500,
              },
            },
            <String, Object>{
              'label': '18',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '19',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '20',
              'value': <String, num>{
                'distanceKm': 20.3,
                'elevationGainM': 180,
                'durationSec': 3100,
              },
            },
            <String, Object>{
              'label': '21',
              'value': <String, num>{
                'distanceKm': 27.1,
                'elevationGainM': 350,
                'durationSec': 3900,
              },
            },
            <String, Object>{
              'label': '22',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '23',
              'value': <String, num>{
                'distanceKm': 14.5,
                'elevationGainM': 110,
                'durationSec': 2200,
              },
            },
            <String, Object>{
              'label': '24',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '25',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '26',
              'value': <String, num>{
                'distanceKm': 0.0,
                'elevationGainM': 0,
                'durationSec': 0,
              },
            },
            <String, Object>{
              'label': '27',
              'value': <String, num>{
                'distanceKm': 33.2,
                'elevationGainM': 380,
                'durationSec': 4500,
              },
            },
            <String, Object>{
              'label': '28',
              'value': <String, num>{
                'distanceKm': 21.7,
                'elevationGainM': 240,
                'durationSec': 3300,
              },
            },
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
                'distanceKm': 18.9,
                'elevationGainM': 160,
                'durationSec': 2700,
              },
            },
            <String, Object>{
              'label': '31',
              'value': <String, num>{
                'distanceKm': 15.4,
                'elevationGainM': 125,
                'durationSec': 2340,
              },
            },
          ],
        };
      case StatisticPeriodType.year:
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
          'details': <Map<String, Object>>[
            // 1월부터 12월까지
            <String, Object>{
              'label': '1월',
              'value': <String, num>{
                'distanceKm': 95.2,
                'elevationGainM': 980,
                'durationSec': 12600,
              },
            },
            <String, Object>{
              'label': '2월',
              'value': <String, num>{
                'distanceKm': 102.8,
                'elevationGainM': 1120,
                'durationSec': 13800,
              },
            },
            <String, Object>{
              'label': '3월',
              'value': <String, num>{
                'distanceKm': 158.4,
                'elevationGainM': 1650,
                'durationSec': 18900,
              },
            },
            <String, Object>{
              'label': '4월',
              'value': <String, num>{
                'distanceKm': 187.6,
                'elevationGainM': 2100,
                'durationSec': 21600,
              },
            },
            <String, Object>{
              'label': '5월',
              'value': <String, num>{
                'distanceKm': 203.5,
                'elevationGainM': 2350,
                'durationSec': 24300,
              },
            },
            <String, Object>{
              'label': '6월',
              'value': <String, num>{
                'distanceKm': 172.9,
                'elevationGainM': 1890,
                'durationSec': 19800,
              },
            },
            <String, Object>{
              'label': '7월',
              'value': <String, num>{
                'distanceKm': 165.7,
                'elevationGainM': 1780,
                'durationSec': 18900,
              },
            },
            <String, Object>{
              'label': '8월',
              'value': <String, num>{
                'distanceKm': 142.3,
                'elevationGainM': 1520,
                'durationSec': 16200,
              },
            },
            <String, Object>{
              'label': '9월',
              'value': <String, num>{
                'distanceKm': 178.4,
                'elevationGainM': 1920,
                'durationSec': 20400,
              },
            },
            <String, Object>{
              'label': '10월',
              'value': <String, num>{
                'distanceKm': 156.8,
                'elevationGainM': 1680,
                'durationSec': 17700,
              },
            },
            <String, Object>{
              'label': '11월',
              'value': <String, num>{
                'distanceKm': 89.4,
                'elevationGainM': 890,
                'durationSec': 10800,
              },
            },
            <String, Object>{
              'label': '12월',
              'value': <String, num>{
                'distanceKm': 36.3,
                'elevationGainM': 490,
                'durationSec': 5400,
              },
            },
          ],
        };
      case StatisticPeriodType.all:
        return <String, dynamic>{
          'period': <String, String>{
            'type': 'all',
            'startDate': '2021-01-01',
            'endDate': '2025-12-31',
            'displayTitle': '전체',
          },
          'summary': <String, num>{
            'totalDistance': 2456.7,
            'totalElevationGain': 18900,
            'totalDuration': 295200, // 82시간
            'totalActivityCount': 48,
          },
          'details': <Map<String, Object>>[
            // 최근 5년간
            <String, Object>{
              'label': '2021',
              'value': <String, num>{
                'distanceKm': 324.5,
                'elevationGainM': 2890,
                'durationSec': 38400,
              },
            },
            <String, Object>{
              'label': '2022',
              'value': <String, num>{
                'distanceKm': 567.8,
                'elevationGainM': 4250,
                'durationSec': 67800,
              },
            },
            <String, Object>{
              'label': '2023',
              'value': <String, num>{
                'distanceKm': 678.2,
                'elevationGainM': 5120,
                'durationSec': 81000,
              },
            },
            <String, Object>{
              'label': '2024',
              'value': <String, num>{
                'distanceKm': 596.9,
                'elevationGainM': 4980,
                'durationSec': 72600,
              },
            },
            <String, Object>{
              'label': '2025',
              'value': <String, num>{
                'distanceKm': 289.3,
                'elevationGainM': 1660,
                'durationSec': 35400,
              },
            },
          ],
        };
    }
  }
}
