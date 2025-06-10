import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RidingScreen extends StatefulWidget {
  const RidingScreen({super.key});

  @override
  State<RidingScreen> createState() => _RidingScreenState();
}

class _RidingScreenState extends State<RidingScreen> {
  final LatLng initialCenter = const LatLng(37.5665, 126.9780);
  final double initialZoom = 13.0;
  @override
  Widget build(BuildContext context) {
    final String baseUrl =
        dotenv.env['THUNDERFOREST_BASE_URL'] ?? 'fallback_url';
    final String apiKey = dotenv.env['THUNDERFOREST_API_KEY'] ?? 'fallback_key';
    final String fullUrlTemplate = '$baseUrl?apikey=$apiKey';

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: <Widget>[
        TileLayer(
          urlTemplate: fullUrlTemplate,
          userAgentPackageName: 'com.example.ridingmate',
        ),
      ],
    );
  }
}
