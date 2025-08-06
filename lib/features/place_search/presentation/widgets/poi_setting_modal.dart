import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/button/icon_button_solid.dart';
import 'package:ridingmate/shared/design_system/widgets/icon/icon_size.dart';
import 'package:ridingmate/shared/design_system/widgets/modal/bottom_sheet_modal.dart';

class PoiSettingModal extends StatefulWidget {
  const PoiSettingModal({super.key});

  static Future<void> show({required BuildContext context}) {
    return BottomSheetShow.show(
      context: context,
      title: '지도 설정',
      content: const PoiSettingModal(),
      showCloseButton: true,
    );
  }

  @override
  State<PoiSettingModal> createState() => _PoiSettingModalState();
}

class _PoiSettingModalState extends State<PoiSettingModal> {
  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
            children: <Widget>[
              _buildPoiButton(
                context,
                icon: Icons.restaurant,
                label: '음식점',
                color: colors.primaryNormal,
                onTap: () {},
              ),
              _buildPoiButton(
                context,
                icon: Icons.local_cafe,
                label: '카페',
                color: colors.primaryNormal,
                onTap: () {},
              ),
              _buildPoiButton(
                context,
                icon: Icons.local_convenience_store,
                label: '편의점',
                color: colors.primaryNormal,
                onTap: () {},
              ),
              _buildPoiButton(
                context,
                icon: Icons.local_pharmacy,
                label: '약국',
                color: colors.primaryNormal,
                onTap: () {},
              ),
              _buildPoiButton(
                context,
                icon: Icons.wc,
                label: '화장실',
                color: colors.primaryNormal,
                onTap: () {},
              ),
              _buildPoiButton(
                context,
                icon: Icons.local_parking,
                label: '주차 시설',
                color: colors.primaryNormal,
                onTap: () {},
              ),
              _buildPoiButton(
                context,
                icon: Icons.build,
                label: '수리 시설',
                color: colors.primaryNormal,
                onTap: () {},
              ),
              _buildPoiButton(
                context,
                icon: Icons.local_gas_station,
                label: '공기 주입기',
                color: colors.primaryNormal,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoiButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final SemanticColors colors = context.semanticColor;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButtonSolid(
            icon: icon,
            onPressed: onTap,
            iconSize: IconSize.xlarge,
            backgroundColor: colors.primaryNormal,
            iconColor: colors.staticWhite,
            customButtonSize: 48,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption2.medium.copyWith(
              color: colors.primaryNormal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
