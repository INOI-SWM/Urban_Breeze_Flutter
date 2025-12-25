import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/modal/modal_show.dart';

/// 서비스 종료 안내 팝업
class ServiceTerminationNoticePopup {
  /// 서비스 종료 안내 팝업 표시
  static Future<void> show(BuildContext context) async {
    final SemanticColors colors = context.semanticColor;

    await ModalShow.show(
      context: context,
      title: '서비스 종료 안내',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          'Urban Breeze 서비스가\n2026년 1월 31일부로 종료됩니다.\n\n'
          '그동안 Urban Breeze를 이용해주신\n'
          '모든 분들께 진심으로 감사드립니다.\n\n'
          '서비스 종료 후 개인정보 및 위치정보는\n'
          '안전하게 모두 삭제될 예정입니다.\n\n'
          '서비스 종료 전까지는 정상적으로\n'
          '이용하실 수 있습니다.',
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
