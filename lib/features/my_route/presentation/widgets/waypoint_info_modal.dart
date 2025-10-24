import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/waypoint.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';

/// Waypoint 정보를 보여주는 읽기 전용 모달
class WaypointInfoModal extends StatelessWidget {
  const WaypointInfoModal({required this.waypoint, super.key});

  final Waypoint waypoint;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return GestureDetector(
      onTap: () {
        // 배경 탭 시 키보드 닫기 (여기서는 불필요하지만 일관성 유지)
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.backgroundNormalNormal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 헤더
            _buildHeader(context, colors),
            const SizedBox(height: 20),

            // 컨텐츠
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 타입 정보
                  _buildTypeSection(colors),
                  const SizedBox(height: 20),

                  // 제목
                  if (waypoint.title != null) ...<Widget>[
                    _buildInfoSection(
                      colors: colors,
                      label: '제목',
                      content: waypoint.title!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 설명
                  if (waypoint.description != null) ...<Widget>[
                    _buildInfoSection(
                      colors: colors,
                      label: '설명',
                      content: waypoint.description!,
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),

            // 하단 여백
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 헤더 빌드
  Widget _buildHeader(BuildContext context, SemanticColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.lineNormalNormal, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Waypoint 정보',
            style: AppTextStyles.heading2.bold.copyWith(
              color: colors.labelStrong,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: colors.labelNormal),
          ),
        ],
      ),
    );
  }

  /// 타입 섹션 빌드
  Widget _buildTypeSection(SemanticColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundElevatedAlternative,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primaryNormal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              waypoint.type.icon,
              color: colors.primaryNormal,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '타입',
                  style: AppTextStyles.label2.medium.copyWith(
                    color: colors.labelAlternative,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  waypoint.type.displayName,
                  style: AppTextStyles.body1.normalRegular.copyWith(
                    color: colors.labelStrong,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 섹션 빌드 (제목, 설명 등)
  Widget _buildInfoSection({
    required SemanticColors colors,
    required String label,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.label1.normalMedium.copyWith(
            color: colors.labelAlternative,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.backgroundElevatedAlternative,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: AppTextStyles.body1.normalRegular.copyWith(
              color: colors.labelNormal,
            ),
          ),
        ),
      ],
    );
  }

  /// 모달 표시 헬퍼 메서드
  static Future<void> show(BuildContext context, {required Waypoint waypoint}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return WaypointInfoModal(waypoint: waypoint);
      },
    );
  }
}
