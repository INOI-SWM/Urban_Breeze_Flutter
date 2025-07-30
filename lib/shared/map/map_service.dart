import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapService {
  MapService._();

  static String getGeoapifyUrlTemplate() {
    final String baseUrl = dotenv.env['GEOAPIFY_BASE_URL'] ?? 'fallback_url';
    final String apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? 'fallback_key';
    return '$baseUrl?&apiKey=$apiKey';
  }
}
