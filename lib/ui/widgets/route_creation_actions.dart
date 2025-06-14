import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/design_system/Icon/icon_size.dart';
import 'package:ridingmate/design_system/button/icon_button_solid.dart';
import 'package:ridingmate/design_system/effect/app_shadows.dart';

class RouteCreationActions extends StatelessWidget {
  const RouteCreationActions({
    super.key,
    required this.isButtonPressed,
    required this.onToggleButton,
    required this.onRemoveLastPin,
    required this.onMoveToCurrentLocation,
    required this.hasPins,
  });
  static const IconSize _iconSize = IconSize.medium;
  static const IconButtonSize _buttonSize = IconButtonSize.medium;

  final bool isButtonPressed;
  final VoidCallback onToggleButton;
  final VoidCallback onRemoveLastPin;
  final VoidCallback onMoveToCurrentLocation;
  final bool hasPins;

  @override
  Widget build(BuildContext context) {
    final Color pinButtonBg =
        isButtonPressed
            ? context.semanticColor.primaryNormal
            : context.semanticColor.backgroundNormalNormal;
    final Color pinButtonIcon =
        isButtonPressed
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
          onPressed: onToggleButton,
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
          onPressed: onMoveToCurrentLocation,
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
