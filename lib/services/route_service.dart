import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/route_result.dart';

enum RouteMode {
  drivingCar,
  cyclingRegular,
  cyclingRoad,
  cyclingMountain,
  cyclingElectric,
}

extension RouteModeExtension on RouteMode {
  String get apiValue {
    switch (this) {
      case RouteMode.drivingCar:
        return 'driving-car';
      case RouteMode.cyclingRegular:
        return 'cycling-regular';
      case RouteMode.cyclingRoad:
        return 'cycling-road';
      case RouteMode.cyclingMountain:
        return 'cycling-mountain';
      case RouteMode.cyclingElectric:
        return 'cycling-electric';
    }
  }
}

class RouteService {
  static final String _apiKey = dotenv.env['OPENROUTE_API_KEY'] ?? '';
  static final String _baseUrl = dotenv.env['ORS_BASE_URL'] ?? '';

  // Elevation 계산 상수
  static const double _minElevationThreshold = 3.0; // 최소 의미있는 상승 (m)
  static const int _smoothingWindow = 5; // 고도 평활화 윈도우 크기
  static const int _elevationIndex = 2; // 좌표 배열에서 고도 인덱스

  /// Strava 스타일 elevation gain 계산
  static double _calculateSmoothedElevationGain(
    List<LatLng> points,
    List<double> elevations,
  ) {
    if (!_isValidElevationData(points, elevations)) return 0.0;

    final List<double> smoothedElevations = _smoothElevations(elevations);
    return _calculateElevationGain(smoothedElevations);
  }

  /// 고도 데이터 유효성 검사
  static bool _isValidElevationData(
    List<LatLng> points,
    List<double> elevations,
  ) {
    return points.length == elevations.length && elevations.length >= 2;
  }

  /// 고도 데이터 평활화
  static List<double> _smoothElevations(List<double> elevations) {
    final List<double> smoothed = List<double>.filled(elevations.length, 0.0);
    final int halfWindow = _smoothingWindow ~/ 2;

    for (int i = 0; i < elevations.length; i++) {
      final ({int end, int start}) range = _calculateSmoothingRange(
        i,
        elevations.length,
        halfWindow,
      );
      smoothed[i] = _calculateAverage(elevations, range.start, range.end);
    }

    return smoothed;
  }

  /// 평활화 범위 계산
  static ({int start, int end}) _calculateSmoothingRange(
    int index,
    int length,
    int halfWindow,
  ) {
    return (
      start: (index - halfWindow).clamp(0, length - 1),
      end: (index + halfWindow).clamp(0, length - 1),
    );
  }

  /// 구간 평균 계산
  static double _calculateAverage(List<double> values, int start, int end) {
    double sum = 0.0;
    int count = 0;

    for (int i = start; i <= end; i++) {
      sum += values[i];
      count++;
    }

    return sum / count;
  }

  /// 실제 elevation gain 계산
  static double _calculateElevationGain(List<double> elevations) {
    double totalGain = 0.0;
    double climbStart = elevations[0];
    double currentElevation = elevations[0];
    bool isClimbing = false;

    for (int i = 1; i < elevations.length; i++) {
      final double elevation = elevations[i];
      final ({double climbStart, double gainToAdd, bool isClimbing})
      climbState = _processElevationChange(
        currentElevation,
        elevation,
        isClimbing,
        climbStart,
      );

      totalGain += climbState.gainToAdd;
      isClimbing = climbState.isClimbing;
      climbStart = climbState.climbStart;
      currentElevation = elevation;
    }

    // 마지막 상승 구간 처리
    if (isClimbing) {
      final double finalGain = currentElevation - climbStart;
      if (finalGain >= _minElevationThreshold) {
        totalGain += finalGain;
      }
    }

    return totalGain;
  }

  /// 고도 변화 처리
  static ({double gainToAdd, bool isClimbing, double climbStart})
  _processElevationChange(
    double currentElevation,
    double newElevation,
    bool isClimbing,
    double climbStart,
  ) {
    if (newElevation > currentElevation) {
      // 상승 중
      return (
        gainToAdd: 0.0,
        isClimbing: true,
        climbStart: isClimbing ? climbStart : currentElevation,
      );
    } else if (newElevation < currentElevation && isClimbing) {
      // 하강 시작 - 상승 구간 종료
      final double climbGain = currentElevation - climbStart;
      return (
        gainToAdd: climbGain >= _minElevationThreshold ? climbGain : 0.0,
        isClimbing: false,
        climbStart: climbStart,
      );
    }

    // 고도 변화 없음 또는 하강 중
    return (gainToAdd: 0.0, isClimbing: isClimbing, climbStart: climbStart);
  }

  /// 좌표에서 고도 데이터 추출
  static List<double> _extractElevations(List<List<dynamic>> coordinates) {
    return coordinates
        .map(
          (List coord) =>
              coord.length > _elevationIndex
                  ? (coord[_elevationIndex] as num).toDouble()
                  : 0.0,
        )
        .toList();
  }

  /// 좌표에서 LatLng 포인트 추출
  static List<LatLng> _extractPoints(List<List<dynamic>> coordinates) {
    return coordinates
        .map((List coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
        .toList();
  }

  static RouteResult _parseRouteResponse(Map<String, dynamic> data) {
    final List<List> coordinates =
        (data['features'][0]['geometry']['coordinates'] as List<dynamic>)
            .cast<List<dynamic>>();

    final List<LatLng> points = _extractPoints(coordinates);
    final List<double> elevations = _extractElevations(coordinates);

    final Map<String, dynamic> properties =
        data['features'][0]['properties'] as Map<String, dynamic>;
    final Map<String, dynamic> summary =
        properties['summary'] as Map<String, dynamic>;

    return RouteResult(
      points: points,
      distance: (summary['distance'] as num).toDouble(),
      duration: (summary['duration'] as num).toDouble(),
      ascent: (properties['ascent'] as num?)?.toDouble() ?? 0.0,
      descent: (properties['descent'] as num?)?.toDouble() ?? 0.0,
      elevationGain: _calculateSmoothedElevationGain(points, elevations),
    );
  }

  static Future<RouteResult?> getRoute(
    LatLng start,
    LatLng end, {
    RouteMode mode = RouteMode.cyclingRoad,
  }) async {
    try {
      final http.Response response = await _makeRouteRequest(start, end, mode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body) as Map<String, dynamic>;
        return _parseRouteResponse(data);
      }

      //todo: 200이 아닌 경우 띄울 에러메시지, 동작 및 디자인 추가
      return null;
    } catch (e) {
      //파싱, 네트워크 에러 등 예외처리 필요
      return null;
    }
  }

  /// 라우트 API 요청
  static Future<http.Response> _makeRouteRequest(
    LatLng start,
    LatLng end,
    RouteMode mode,
  ) {
    final String url = '$_baseUrl${mode.apiValue}/geojson';
    final Map<String, Object> body = <String, Object>{
      'coordinates': <List<double>>[
        <double>[start.longitude, start.latitude],
        <double>[end.longitude, end.latitude],
      ],
      'elevation': true,
    };

    return http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Accept':
            'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        'Authorization': _apiKey.isNotEmpty ? _apiKey : '',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: json.encode(body),
    );
  }
}
