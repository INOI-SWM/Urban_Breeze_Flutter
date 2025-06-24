import 'dart:math' as math;

class BboxService {
  const BboxService();

  List<double>? mergeBboxes(List<List<double>?> bboxes) {
    final List<List<double>> validBboxes =
        bboxes
            .where((List<double>? bbox) => isValidBbox(bbox))
            .cast<List<double>>()
            .toList();

    if (validBboxes.isEmpty) {
      return null;
    }

    if (validBboxes.length == 1) {
      return List<double>.from(validBboxes.first);
    }

    double minLng = validBboxes.first[0];
    double minLat = validBboxes.first[1];
    double maxLng = validBboxes.first[2];
    double maxLat = validBboxes.first[3];

    for (final List<double> bbox in validBboxes.skip(1)) {
      minLng = math.min(minLng, bbox[0]);
      minLat = math.min(minLat, bbox[1]);
      maxLng = math.max(maxLng, bbox[2]);
      maxLat = math.max(maxLat, bbox[3]);
    }

    return <double>[minLng, minLat, maxLng, maxLat];
  }

  List<double> expandBbox(List<double> bbox, {double paddingRatio = 0.1}) {
    if (!isValidBbox(bbox)) {
      throw ArgumentError('Invalid bbox provided');
    }

    final double lngRange = bbox[2] - bbox[0];
    final double latRange = bbox[3] - bbox[1];

    final double lngPadding = lngRange * paddingRatio;
    final double latPadding = latRange * paddingRatio;

    return <double>[
      bbox[0] - lngPadding,
      bbox[1] - latPadding,
      bbox[2] + lngPadding,
      bbox[3] + latPadding,
    ];
  }

  bool isValidBbox(List<double>? bbox) {
    if (bbox == null || bbox.length != 4) {
      return false;
    }

    final double minLng = bbox[0];
    final double minLat = bbox[1];
    final double maxLng = bbox[2];
    final double maxLat = bbox[3];

    if (minLng >= maxLng || minLat >= maxLat) {
      return false;
    }

    if (minLng < -180 || maxLng > 180 || minLat < -90 || maxLat > 90) {
      return false;
    }

    return true;
  }

  String bboxToString(List<double>? bbox) {
    if (!isValidBbox(bbox)) {
      return 'Invalid bbox';
    }

    return 'BBox(minLng: ${bbox![0].toStringAsFixed(6)}, '
        'minLat: ${bbox[1].toStringAsFixed(6)}, '
        'maxLng: ${bbox[2].toStringAsFixed(6)}, '
        'maxLat: ${bbox[3].toStringAsFixed(6)})';
  }
}
