import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/modal/modal_show.dart';

/// Terra 연동 서비스 일시 중단 안내 팝업
class TerraServiceNoticePopup {
  /// Terra 서비스 일시 중단 안내 팝업 표시
  static Future<void> show(BuildContext context) async {
    final SemanticColors colors = context.semanticColor;

    await ModalShow.show(
      context: context,
      title: '연동 서비스 일시 중단 안내',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          'Garmin, Suunto, Wahoo 연동 서비스가\n2025년 11월 21일부로 잠시 중단됩니다.\n\n'
          '안정적인 서비스 제공을 위한 조치이며,\n'
          '가민, 와후와의 요청이 완료되어 기능을 개발중입니다.\n\n'
          '최대한 빠른 시일내에 다시 기능을 제공할 예정입니다.\n\n'
          'Apple Health를 통한 운동 기록 연동은\n계속 이용 가능합니다.',
          style: AppTextStyles.body2.normalRegular.copyWith(
            color: colors.labelNormal,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      primaryButtonText: '확인',
      onPrimaryButtonPressed: () {
        // 확인 버튼 - 모달 자동 닫힘
      },
    );
  }
}
