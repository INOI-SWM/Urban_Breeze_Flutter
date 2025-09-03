import 'package:flutter/material.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/route_bar_layout.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/route_stats_row.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_size.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_solid.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/text_field/custom_text_field.dart';

enum RouteCreateMode { create, save }

class RouteCreateBottomPanel extends StatefulWidget {
  const RouteCreateBottomPanel({
    super.key,
    required this.mode,
    required this.totalDistance,
    required this.totalDuration,
    required this.elevationGain,
    this.hasRoute = false,
    this.onSave,
    this.onBack,
    this.onComplete,
  });

  final RouteCreateMode mode;
  final String totalDistance;
  final String totalDuration;
  final String elevationGain;
  final bool hasRoute;

  final VoidCallback? onSave;
  final VoidCallback? onBack;
  final ValueChanged<String>? onComplete;

  @override
  State<RouteCreateBottomPanel> createState() => _RouteCreateBottomPanelState();
}

class _RouteCreateBottomPanelState extends State<RouteCreateBottomPanel> {
  late final TextEditingController _titleController;
  late final FocusNode _focusNode;
  bool _isCompleteButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _focusNode = FocusNode();
    _titleController.addListener(_onTextChanged);

    if (widget.mode == RouteCreateMode.save) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(RouteCreateBottomPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode && widget.mode == RouteCreateMode.save) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTextChanged);
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final bool isEnabled = _titleController.text.trim().isNotEmpty;
    if (_isCompleteButtonEnabled != isEnabled) {
      setState(() {
        _isCompleteButtonEnabled = isEnabled;
      });
    }
  }

  void _handleComplete() {
    final String title = _titleController.text.trim();
    _titleController.clear();
    widget.onComplete?.call(title);
  }

  Widget _buildTopNavigationBar(SemanticColors colors) {
    switch (widget.mode) {
      case RouteCreateMode.create:
        return CustomAppBar(
          title: '경로 생성',
          centerTitle: false,
          titleTextSize: AppBarTitleSize.large,
          actions: <Widget>[
            // ButtonSolid(
            //   text: '지도 설정',
            //   size: ButtonSize.small,
            //   backgroundColor: colors.fillNormal,
            //   textColor: colors.labelNeutral,
            //   onPressed: () {
            //     AmplitudeAnalytics.logButtonClick(
            //       'route_planning_map_settings',
            //     );
            //     PoiSettingModal.show(context: context);
            //   },
            // ),
            ButtonSolid(
              text: '저장',
              size: ButtonSize.small,
              backgroundColor:
                  widget.hasRoute
                      ? colors.primaryNormal
                      : colors.interactionDisable,
              textColor:
                  widget.hasRoute ? colors.staticWhite : colors.labelAssistive,
              onPressed:
                  widget.hasRoute
                      ? () {
                        AmplitudeAnalytics.logButtonClick(
                          'route_planning_save_button',
                        );
                        widget.onSave?.call();
                      }
                      : null,
            ),
          ],
        );

      case RouteCreateMode.save:
        return CustomAppBar(
          title: '경로 저장',
          centerTitle: true,
          titleTextSize: AppBarTitleSize.large,
          leading: CustomIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () {
              AmplitudeAnalytics.logButtonClick('route_planning_save_back');
              widget.onBack?.call();
            },
          ),
          actions: <Widget>[
            ButtonSolid(
              text: '완료',
              size: ButtonSize.small,
              backgroundColor:
                  _isCompleteButtonEnabled
                      ? colors.primaryNormal
                      : colors.interactionDisable,
              textColor:
                  _isCompleteButtonEnabled
                      ? colors.staticWhite
                      : colors.labelAssistive,
              onPressed:
                  _isCompleteButtonEnabled
                      ? () {
                        AmplitudeAnalytics.logButtonClick(
                          'route_planning_save_complete',
                        );
                        _handleComplete();
                      }
                      : null,
            ),
          ],
        );
    }
  }

  Widget _buildContent() {
    switch (widget.mode) {
      case RouteCreateMode.create:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: RouteStatsRow(
            totalDistance: widget.totalDistance,
            totalDuration: widget.totalDuration,
            elevationGain: widget.elevationGain,
          ),
        );

      case RouteCreateMode.save:
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomTextField(
                controller: _titleController,
                focusNode: _focusNode,
                hintText: '경로 명을 입력하세요',
              ),
              const SizedBox(height: 12),
              RouteStatsRow(
                totalDistance: widget.totalDistance,
                totalDuration: widget.totalDuration,
                elevationGain: widget.elevationGain,
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return RouteBarLayout(
      topNavigationBar: _buildTopNavigationBar(colors),
      content: _buildContent(),
    );
  }
}
