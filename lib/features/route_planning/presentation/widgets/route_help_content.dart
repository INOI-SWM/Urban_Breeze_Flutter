import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';

class RouteHelpContent extends StatelessWidget {
  const RouteHelpContent({required this.colors, super.key});

  final SemanticColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHelpSection(
            colors: colors,
            emoji: '📍',
            title: '핀 찍기',
            items: <String>[
              '핀 버튼을 눌러 활성화 (파란색)',
              '지도를 탭하여 경로 지점 추가',
              '2개 이상 찍으면 자동으로 경로 생성',
              '최대 99개까지 추가 가능',
            ],
          ),
          const SizedBox(height: 16),
          _buildHelpSection(
            colors: colors,
            emoji: '🔄',
            title: '되돌리기',
            items: <String>['마지막에 찍은 핀 제거'],
          ),
          const SizedBox(height: 16),
          _buildHelpSection(
            colors: colors,
            emoji: '📌',
            title: 'Waypoint 설정',
            items: <String>[
              '생성되어있는 숫자 핀을 탭 \n(핀 활성화를 끄면 더 잘 눌립니다)',
              '타입 선택 (정상, 보급, 위험 등)',
              '제목/설명 입력 (선택)',
            ],
          ),
          const SizedBox(height: 16),
          _buildHelpSection(
            colors: colors,
            emoji: '💾',
            title: '저장하기',
            items: <String>['경로 생성 완료', '하단의 저장 버튼 클릭', '경로 제목 입력 후 저장'],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection({
    required SemanticColors colors,
    required String emoji,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.headline2.bold.copyWith(
                color: colors.staticBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...items.map(
          (String item) => Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '• ',
                  style: AppTextStyles.label1.normalMedium.copyWith(
                    color: colors.staticBlack,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: AppTextStyles.label1.normalMedium.copyWith(
                      color: colors.staticBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
