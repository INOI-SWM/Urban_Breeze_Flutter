import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/button/button_size.dart';
import 'package:ridingmate/design_system/button/button_solid.dart';
import 'package:ridingmate/design_system/input/custom_text_field.dart';
import 'package:ridingmate/design_system/navigation/top_navigation_bar.dart';
import 'package:ridingmate/ui/widgets/route_stats_row.dart';

class RouteSaveBar extends StatefulWidget {
  const RouteSaveBar({
    super.key,
    required this.totalDistance,
    required this.totalDuration,
    required this.elevationGain,
    this.onBack,
    this.onComplete,
  });

  final String totalDistance;
  final String totalDuration;
  final String elevationGain;
  final VoidCallback? onBack;
  final ValueChanged<String>? onComplete;

  @override
  State<RouteSaveBar> createState() => _RouteSaveBarState();
}

class _RouteSaveBarState extends State<RouteSaveBar> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleComplete() {
    widget.onComplete?.call(_titleController.text);
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Material(
      elevation: 8,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TopNavigationBar(
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
          ),
          Padding(
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
          ),
        ],
      ),
    );
  }
}
