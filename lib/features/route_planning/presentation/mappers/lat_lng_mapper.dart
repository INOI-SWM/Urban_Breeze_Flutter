import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:latlong2/latlong.dart' as latlong2;

/// 좌표 변환을 담당하는 매퍼
class LatLngMapper {
  LatLngMapper._();

  /// latlong2.LatLng를 kakao.LatLng로 변환
  static kakao.LatLng toKakaoLatLng(latlong2.LatLng latLng) {
    return kakao.LatLng(latLng.latitude, latLng.longitude);
  }

  /// latlong2.LatLng 리스트를 kakao.LatLng 리스트로 변환
  static List<kakao.LatLng> toKakaoLatLngList(
    List<latlong2.LatLng> latLngList,
  ) {
    return latLngList
        .map((latlong2.LatLng latLng) => toKakaoLatLng(latLng))
        .toList();
  }

  /// kakao.LatLng를 latlong2.LatLng로 변환
  static latlong2.LatLng toLatlong2LatLng(kakao.LatLng latLng) {
    return latlong2.LatLng(latLng.latitude, latLng.longitude);
  }

  /// kakao.LatLng 리스트를 latlong2.LatLng 리스트로 변환
  static List<latlong2.LatLng> toLatlong2LatLngList(
    List<kakao.LatLng> latLngList,
  ) {
    return latLngList
        .map((kakao.LatLng latLng) => toLatlong2LatLng(latLng))
        .toList();
  }
}
