import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/waypoint.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_outlined.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_size.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_solid.dart';
import 'package:urban_breeze/shared/design_system/widgets/text_field/custom_text_field.dart';

class WaypointSettingModal extends StatefulWidget {
  const WaypointSettingModal({
    super.key,
    required this.position,
    this.initialWaypoint,
    this.onSave,
    this.onDelete,
  });

  final LatLng position;
  final Waypoint? initialWaypoint;
  final ValueChanged<Waypoint>? onSave;
  final VoidCallback? onDelete;

  @override
  State<WaypointSettingModal> createState() => _WaypointSettingModalState();
}

class _WaypointSettingModalState extends State<WaypointSettingModal> {
  late WaypointType _selectedType;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    if (widget.initialWaypoint != null) {
      _selectedType = widget.initialWaypoint!.type;
      _titleController = TextEditingController(
        text: widget.initialWaypoint!.title ?? '',
      );
      _descriptionController = TextEditingController(
        text: widget.initialWaypoint!.description ?? '',
      );
    } else {
      _selectedType = WaypointType.generic;
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    final String? title =
        _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim();
    final String? description =
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim();

    final Waypoint waypoint = Waypoint(
      type: _selectedType,
      title: title,
      description: description,
    );

    widget.onSave?.call(waypoint);
    Navigator.of(context).pop();
  }

  void _onDelete() {
    widget.onDelete?.call();
    Navigator.of(context).pop();
  }

  TextStyle _getLabelStyle(SemanticColors colors) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: colors.labelNormal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return GestureDetector(
      onTap: () {
        // 화면의 다른 부분을 클릭하면 키보드 닫기
        FocusScope.of(context).unfocus();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.backgroundNormalNormal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 헤더
            Row(
              children: <Widget>[
                Icon(Icons.place, color: colors.primaryNormal, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Waypoint 설정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.labelNormal,
                  ),
                ),
                const Spacer(),
                if (widget.initialWaypoint != null)
                  IconButton(
                    onPressed: _onDelete,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                  )
                else
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: colors.labelNormal),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 제목 입력
            Text('제목', style: _getLabelStyle(colors)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _titleController,
              hintText: '예: 한강공원 휴식',
            ),
            const SizedBox(height: 24),

            // 설명 입력
            Text('설명 (선택사항)', style: _getLabelStyle(colors)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _descriptionController,
              hintText: '추가 정보를 입력하세요',
            ),
            const SizedBox(height: 24),
            // Waypoint 타입 선택
            Text('타입', style: _getLabelStyle(colors)),
            const SizedBox(height: 8),
            _buildTypeSelector(colors),

            // 버튼들
            Row(
              children: <Widget>[
                Expanded(
                  child: ButtonOutlined(
                    text: '취소',
                    textColor: colors.labelNormal,
                    borderColor: colors.lineNormalNormal,
                    onPressed: () => Navigator.of(context).pop(),
                    size: ButtonSize.large,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ButtonSolid(
                    text: '저장',
                    textColor: colors.staticWhite,
                    backgroundColor: colors.primaryNormal,
                    onPressed: _onSave,
                    size: ButtonSize.large,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(SemanticColors colors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4열로 배치
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2, // 가로:세로 비율
      ),
      itemCount: WaypointType.values.length,
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (BuildContext context, int index) {
        final WaypointType type = WaypointType.values[index];
        final bool isSelected = _selectedType == type;

        return GestureDetector(
          onTap: () {
            // 키보드 닫기
            FocusScope.of(context).unfocus();
            setState(() {
              _selectedType = type;
              // 제목이 비어있으면 타입명을 제목에 입력
              if (_titleController.text.trim().isEmpty) {
                _titleController.text = type.displayName;
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? colors.primaryNormal
                      : colors.backgroundNormalAlternative,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? colors.primaryNormal : colors.lineNormalNormal,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  type.icon,
                  size: 20,
                  color: isSelected ? colors.staticWhite : colors.labelNormal,
                ),
                const SizedBox(height: 8),
                Text(
                  type.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? colors.staticWhite : colors.labelNormal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
