import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/design_system/Icon/icon_size.dart';
import 'package:ridingmate/design_system/button/icon_button_solid.dart';
import 'package:ridingmate/design_system/effect/app_shadows.dart';

class MapControls extends StatelessWidget {
  const MapControls({
    super.key,
    required this.isButtonPressed,
    required this.onToggleButton,
    required this.onRemoveLastPin,
    required this.onMoveToCurrentLocation,
    required this.hasPins,
  });

  final bool isButtonPressed;
  final VoidCallback onToggleButton;
  final VoidCallback onRemoveLastPin;
  final VoidCallback onMoveToCurrentLocation;
  final bool hasPins;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButtonSolid(
          icon: Icons.push_pin,
          onPressed: onToggleButton,
          iconSize: IconSize.medium,
          backgroundColor:
              isButtonPressed
                  ? context.semanticColor.primaryNormal
                  : context.semanticColor.backgroundNormalNormal,
          iconColor:
              isButtonPressed
                  ? context.semanticColor.staticWhite
                  : context.semanticColor.labelNormal,
          buttonSize: IconButtonSize.medium,
          shadow: AppShadows.instance.emphasize,
        ),
        const SizedBox(height: 12),
        IconButtonSolid(
          icon: Icons.replay,
          onPressed: hasPins ? onRemoveLastPin : () {},
          iconSize: IconSize.medium,
          backgroundColor:
              hasPins
                  ? context.semanticColor.backgroundNormalNormal
                  : context.semanticColor.interactionInactive,
          iconColor:
              hasPins
                  ? context.semanticColor.labelNormal
                  : context.semanticColor.labelDisable,
          buttonSize: IconButtonSize.medium,
          shadow: AppShadows.instance.emphasize,
          isDisabled: !hasPins,
        ),
        const SizedBox(height: 12),
        IconButtonSolid(
          icon: Icons.my_location,
          onPressed: onMoveToCurrentLocation,
          iconSize: IconSize.medium,
          backgroundColor: context.semanticColor.backgroundNormalNormal,
          iconColor: context.semanticColor.labelNormal,
          buttonSize: IconButtonSize.medium,
          shadow: AppShadows.instance.emphasize,
        ),
      ],
    );
  }
}
