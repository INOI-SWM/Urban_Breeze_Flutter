import 'package:latlong2/latlong.dart';

class ElevationCalculateService {
  static const double _minElevationThreshold = 3.0;
  static const int _smoothingWindow = 5;

  static double calculateSmoothedElevationGain(
    List<LatLng> points,
    List<double> elevations,
  ) {
    final List<double> smoothedElevations = _smoothElevations(elevations);
    return _calculateElevationGain(smoothedElevations);
  }

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

  static double _calculateAverage(List<double> values, int start, int end) {
    double sum = 0.0;
    int count = 0;

    for (int i = start; i <= end; i++) {
      sum += values[i];
      count++;
    }

    return sum / count;
  }

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

    if (isClimbing) {
      final double finalGain = currentElevation - climbStart;
      if (finalGain >= _minElevationThreshold) {
        totalGain += finalGain;
      }
    }

    return totalGain;
  }

  static ({double gainToAdd, bool isClimbing, double climbStart})
  _processElevationChange(
    double currentElevation,
    double newElevation,
    bool isClimbing,
    double climbStart,
  ) {
    if (newElevation > currentElevation) {
      return (
        gainToAdd: 0.0,
        isClimbing: true,
        climbStart: isClimbing ? climbStart : currentElevation,
      );
    } else if (newElevation < currentElevation && isClimbing) {
      final double climbGain = currentElevation - climbStart;
      return (
        gainToAdd: climbGain >= _minElevationThreshold ? climbGain : 0.0,
        isClimbing: false,
        climbStart: climbStart,
      );
    }

    return (gainToAdd: 0.0, isClimbing: isClimbing, climbStart: climbStart);
  }
}
