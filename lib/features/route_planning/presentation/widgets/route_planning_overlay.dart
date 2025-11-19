import 'package:flutter/material.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/route_create_bottom_panel.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/route_creation_actions.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/floating_search_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';

class RoutePlanningOverlay extends StatelessWidget {
  const RoutePlanningOverlay({
    super.key,
    required this.isRouteLoading,
    required this.isSaveMode,
    required this.isSearchActive,
    required this.searchText,
    required this.isPinButtonPressed,
    required this.hasPins,
    required this.totalDistance,
    required this.totalDuration,
    required this.elevationGain,
    required this.hasRoute,
    required this.onSearchTap,
    required this.onCloseTap,
    required this.onClearTap,
    required this.onTogglePinButton,
    required this.onRemoveLastPin,
    required this.onMoveToCurrentLocation,
    required this.onSave,
    required this.onBack,
    required this.onComplete,
  });

  final bool isRouteLoading;
  final bool isSaveMode;
  final bool isSearchActive;
  final String searchText;
  final bool isPinButtonPressed;
  final bool hasPins;
  final String totalDistance;
  final String totalDuration;
  final String elevationGain;
  final bool hasRoute;

  final VoidCallback onSearchTap;
  final VoidCallback onCloseTap;
  final VoidCallback onClearTap;
  final VoidCallback onTogglePinButton;
  final VoidCallback onRemoveLastPin;
  final VoidCallback onMoveToCurrentLocation;
  final VoidCallback onSave;
  final VoidCallback onBack;
  final ValueChanged<String> onComplete;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: <Widget>[
          if (isRouteLoading)
            const Positioned.fill(child: Center(child: AppLoadingIndicator())),
          if (!isSaveMode)
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: FloatingSearchAppBar(
                searchText: searchText,
                onSearchTap: onSearchTap,
                onCloseTap: onCloseTap,
                onClearTap: onClearTap,
                isSearchActive: isSearchActive,
              ),
            ),
          // 하단 UI (액션 버튼 + 바텀 패널)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (!isSaveMode)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 16),
                        child: AbsorbPointer(
                          absorbing: isRouteLoading,
                          child: Opacity(
                            opacity: isRouteLoading ? 0.5 : 1.0,
                            child: RouteCreationActionButtons(
                              isPinButtonPressed: isPinButtonPressed,
                              onTogglePinButton: onTogglePinButton,
                              onRemoveLastPin: onRemoveLastPin,
                              onMoveToCurrentLocation: onMoveToCurrentLocation,
                              hasPins: hasPins,
                            ),
                          ),
                        ),
                      ),
                    ),
                  RouteCreateBottomPanel(
                    mode:
                        isSaveMode
                            ? RouteCreateMode.save
                            : RouteCreateMode.create,
                    totalDistance: totalDistance,
                    totalDuration: totalDuration,
                    elevationGain: elevationGain,
                    hasRoute: hasRoute,
                    onSave: onSave,
                    onBack: onBack,
                    onComplete: onComplete,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
