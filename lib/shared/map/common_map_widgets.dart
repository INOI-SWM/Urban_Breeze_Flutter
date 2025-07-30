import 'package:flutter_map/flutter_map.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/map/map_constants.dart';
import 'package:ridingmate/shared/map/map_service.dart';

class CommonMapWidgets {
  CommonMapWidgets._();

  static TileLayer createTileLayer() {
    return TileLayer(
      urlTemplate: MapService.getGeoapifyUrlTemplate(),
      userAgentPackageName: MapConstants.userAgentPackageName,
      subdomains: MapConstants.subdomains,
    );
  }

  static RichAttributionWidget createAttributionWidget() {
    return RichAttributionWidget(
      alignment: AttributionAlignment.bottomLeft,
      showFlutterMapAttribution: false,
      attributions: <SourceAttribution>[
        TextSourceAttribution(
          MapConstants.attributionText,
          textStyle: AppTextStyles.caption2.regular,
        ),
      ],
    );
  }
}
