import 'package:latlong2/latlong.dart';

class ManageRoutePinsUseCase {
  const ManageRoutePinsUseCase({this.maxPinCount = 50});

  final int maxPinCount;

  bool shouldAddPin(bool isButtonPressed, List<LatLng> pins) {
    return isButtonPressed && pins.length < maxPinCount;
  }

  bool shouldGetRoute(List<LatLng> pins) {
    return pins.length >= 2;
  }
}
