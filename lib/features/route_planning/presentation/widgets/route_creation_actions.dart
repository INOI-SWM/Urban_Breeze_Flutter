import 'package:flutter/material.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/decorations/app_shadows.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/icon_button_solid.dart';
import 'package:urban_breeze/shared/design_system/widgets/icon/icon_size.dart';

class RouteCreationActionButtons extends StatelessWidget {
  const RouteCreationActionButtons({
    super.key,
    required this.isPinButtonPressed,
    required this.onTogglePinButton,
    required this.onRemoveLastPin,
    required this.onMoveToCurrentLocation,
    required this.hasPins,
  });
  static const IconSize _iconSize = IconSize.medium;
  static const IconButtonSize _buttonSize = IconButtonSize.medium;

  final bool isPinButtonPressed;
  final VoidCallback onTogglePinButton;
  final VoidCallback onRemoveLastPin;
  final VoidCallback onMoveToCurrentLocation;
  final bool hasPins;

  @override
  Widget build(BuildContext context) {
    final Color pinButtonBg =
        isPinButtonPressed
            ? context.semanticColor.primaryNormal
            : context.semanticColor.backgroundNormalNormal;
    final Color pinButtonIcon =
        isPinButtonPressed
            ? context.semanticColor.staticWhite
            : context.semanticColor.labelNormal;

    final Color replayButtonBg =
        hasPins
            ? context.semanticColor.backgroundNormalNormal
            : context.semanticColor.interactionInactive;
    final Color replayButtonIcon =
        hasPins
            ? context.semanticColor.labelNormal
            : context.semanticColor.labelDisable;

    final Color locationButtonBg = context.semanticColor.backgroundNormalNormal;
    final Color locationButtonIcon = context.semanticColor.labelNormal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButtonSolid(
          icon: Icons.push_pin,
          onPressed: onTogglePinButton,
          iconSize: _iconSize,
          backgroundColor: pinButtonBg,
          iconColor: pinButtonIcon,
          buttonSize: _buttonSize,
          shadow: AppShadows.instance.emphasize,
        ),
        const SizedBox(height: 12),
        IconButtonSolid(
          icon: Icons.replay,
          onPressed: hasPins ? onRemoveLastPin : () {},
          iconSize: _iconSize,
          backgroundColor: replayButtonBg,
          iconColor: replayButtonIcon,
          buttonSize: _buttonSize,
          shadow: AppShadows.instance.emphasize,
          isDisabled: !hasPins,
        ),
        const SizedBox(height: 12),
        IconButtonSolid(
          icon: Icons.my_location,
          onPressed: () {
            AmplitudeAnalytics.logButtonClick(
              'route_planning_move_to_current_location',
            );
            onMoveToCurrentLocation();
          },
          iconSize: _iconSize,
          backgroundColor: locationButtonBg,
          iconColor: locationButtonIcon,
          buttonSize: _buttonSize,
          shadow: AppShadows.instance.emphasize,
        ),
      ],
    );
  }
}
