class GeometryPoint {
  const GeometryPoint({
    required this.longitude,
    required this.latitude,
    required this.elevation,
  });

  final double longitude; // 경도
  final double latitude; // 위도
  final double elevation; // 경사도
}
