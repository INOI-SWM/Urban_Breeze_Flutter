import '../../../route_planning/domain/services/elevation_calculate_service.dart';
import '../entities/heart_rate_data.dart';
import '../entities/location_data.dart';

class WorkoutCalculationService {
  /// 심박수 데이터 배열에서 평균 심박수 계산
  static double? calculateAverageHeartRate(List<HeartRateData> heartRateData) {
    if (heartRateData.isEmpty) {
      return null;
    }

    final double totalHeartRate = heartRateData.fold(
      0.0,
      (double sum, HeartRateData data) => sum + data.heartRate,
    );

    return totalHeartRate / heartRateData.length;
  }

  /// GPS 위치 데이터에서 elevation gain 계산
  static double? calculateElevationGain(List<LocationData> locationData) {
    if (locationData.isEmpty) {
      return null;
    }

    // 고도 데이터 추출 (null이 아닌 고도만)
    final List<double> elevations =
        locationData
            .where((LocationData data) => data.altitude != null)
            .map((LocationData data) => data.altitude!)
            .toList();

    if (elevations.length < 2) {
      return null;
    }

    // ElevationCalculateService를 사용하여 elevation gain 계산
    return ElevationCalculateService.calculateSmoothedElevationGain(elevations);
  }
}
