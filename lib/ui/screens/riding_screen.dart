import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/design_system/Icon/icon_size.dart';
import 'package:ridingmate/design_system/button/icon_button_solid.dart';
import 'package:ridingmate/design_system/effect/app_shadows.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

class RidingScreen extends StatefulWidget {
  const RidingScreen({super.key});

  @override
  State<RidingScreen> createState() => _RidingScreenState();
}

class _RidingScreenState extends State<RidingScreen> {
  final LatLng initialCenter = const LatLng(37.5665, 126.9780); //서울시청
  final double initialZoom = 16.0;
  LatLng? _currentPosition;
  bool _isLoading = true;
  final MapController _mapController = MapController();
  bool _isButtonPressed = false;
  final List<LatLng> _pins = <LatLng>[];
  // LatLng? _lastTapPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final LocationPermission requestPermission =
            await Geolocator.requestPermission();
        if (requestPermission == LocationPermission.denied) {
          return;
        }
      }

      final Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _moveToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, initialZoom);
    }
  }

  void _toggleButtonState() {
    setState(() {
      _isButtonPressed = !_isButtonPressed;
    });
  }

  void _addPin(LatLng position) {
    if (_isButtonPressed && _pins.length < 50) {
      setState(() {
        _pins.add(position);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String baseUrl =
        dotenv.env['THUNDERFOREST_BASE_URL'] ?? 'fallback_url';
    final String apiKey = dotenv.env['THUNDERFOREST_API_KEY'] ?? 'fallback_key';
    final String fullUrlTemplate = '$baseUrl?apikey=$apiKey';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: <Widget>[
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition ?? initialCenter,
            initialZoom: initialZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onTap: (_, LatLng position) {
              // _lastTapPosition = position;

              _addPin(position);
            },
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate: fullUrlTemplate,
              userAgentPackageName: 'com.example.ridingmate',
              subdomains: const <String>['a', 'b', 'c'],
            ),
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              showFlutterMapAttribution: false,
              attributions: <SourceAttribution>[
                TextSourceAttribution(
                  'Maps: © Thunderforest | Data: © OpenStreetMap contributors',
                  textStyle: AppTextStyles.caption2.regular,
                ),
              ],
            ),
            if (_currentPosition != null)
              MarkerLayer(
                markers: <Marker>[
                  Marker(
                    point: _currentPosition!,
                    width: 32,
                    height: 32,
                    child: Image.asset(
                      'assets/icons/png/current_location_pin.png',
                    ),
                  ),
                ],
              ),
            MarkerLayer(
              markers:
                  _pins.asMap().entries.map((MapEntry<int, LatLng> entry) {
                    final int index = entry.key;
                    final LatLng position = entry.value;
                    return Marker(
                      point: position,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              context.semanticColor.accentBackgroundRedOrange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.caption2.regular.copyWith(
                              color: context.semanticColor.staticWhite,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButtonSolid(
                icon: Icons.push_pin,
                onPressed: _toggleButtonState,
                iconSize: IconSize.medium,
                backgroundColor:
                    _isButtonPressed
                        ? context.semanticColor.primaryNormal
                        : context.semanticColor.backgroundNormalNormal,
                iconColor:
                    _isButtonPressed
                        ? context.semanticColor.staticWhite
                        : context.semanticColor.labelNormal,
                buttonSize: IconButtonSize.medium,
                shadow: AppShadows.instance.emphasize,
              ),
              const SizedBox(height: 12),
              IconButtonSolid(
                icon: Icons.replay,
                onPressed: _pins.isEmpty ? () {} : () {},
                iconSize: IconSize.medium,
                backgroundColor:
                    _pins.isEmpty
                        ? context.semanticColor.interactionInactive
                        : context.semanticColor.backgroundNormalNormal,
                iconColor:
                    _pins.isEmpty
                        ? context.semanticColor.labelDisable
                        : context.semanticColor.labelNormal,
                buttonSize: IconButtonSize.medium,
                shadow: AppShadows.instance.emphasize,
              ),
              const SizedBox(height: 12),
              IconButtonSolid(
                icon: Icons.my_location,
                onPressed: _moveToCurrentLocation,
                iconSize: IconSize.medium,
                backgroundColor: context.semanticColor.backgroundNormalNormal,
                iconColor: context.semanticColor.labelNormal,
                buttonSize: IconButtonSize.medium,
                shadow: AppShadows.instance.emphasize,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
