import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/button/button_size.dart';
import 'package:ridingmate/design_system/button/button_solid.dart';
import 'package:ridingmate/design_system/input/custom_text_field.dart';
import 'package:ridingmate/design_system/navigation/top_navigation_bar.dart';
import 'package:ridingmate/ui/widgets/route_bar_layout.dart';
import 'package:ridingmate/ui/widgets/route_stats_row.dart';

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _focusNode = FocusNode();

    if (widget.mode == RouteCreateMode.save) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleComplete() {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      // todo : 사용자에게 제목 입력 필요 알림 표시
      return;
    }

    _titleController.clear();
    widget.onComplete?.call(title);
  }

  Widget _buildTopNavigationBar(SemanticColors colors) {
    switch (widget.mode) {
      case RouteCreateMode.create:
        return TopNavigationBar(
          title: '경로 생성',
          centerTitle: false,
          titleTextSize: NavBarTitleSize.large,
          actions: <Widget>[
            ButtonSolid(
              text: '저장',
              size: ButtonSize.small,
              backgroundColor:
                  widget.hasRoute
                      ? colors.primaryNormal
                      : colors.interactionDisable,
              textColor:
                  widget.hasRoute ? colors.staticWhite : colors.labelAssistive,
              onPressed: widget.hasRoute ? widget.onSave : null,
            ),
          ],
        );

      case RouteCreateMode.save:
        return TopNavigationBar(
          title: '경로 저장',
          centerTitle: true,
          titleTextSize: NavBarTitleSize.large,
          leading: GestureDetector(
            onTap: widget.onBack,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: Icon(Icons.arrow_back_ios_new, size: 24),
            ),
          ),
          actions: <Widget>[
            ButtonSolid(
              text: '완료',
              size: ButtonSize.small,
              backgroundColor: colors.primaryNormal,
              textColor: colors.staticWhite,
              onPressed: _handleComplete,
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
                autofocus: true,
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
