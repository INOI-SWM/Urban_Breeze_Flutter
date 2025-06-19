import 'package:latlong2/latlong.dart';

class ManageRoutePinsUseCase {
  ManageRoutePinsUseCase({int maxPinCount = 50}) : _maxPinCount = maxPinCount;

  final int _maxPinCount;

  bool shouldAddPin(bool isButtonPressed, List<LatLng> pins) {
    return isButtonPressed && pins.length < _maxPinCount;
  }

  bool shouldGetRoute(List<LatLng> pins) {
    return pins.length >= 2;
  }
}
