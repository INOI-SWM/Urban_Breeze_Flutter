import 'package:flutter/material.dart';

class BottomSheetSizeCalculator {
  BottomSheetSizeCalculator._();

  /// 바텀시트의 최대 크기를 계산합니다.
  ///
  /// [contentKey] 바텀시트 콘텐츠의 GlobalKey
  /// [context] BuildContext
  /// [initialChildSize] 초기 자식 크기
  ///
  /// Returns: 계산된 최대 자식 크기 (0.0 ~ 0.95)
  static double calculateMaxChildSize(
    GlobalKey contentKey,
    BuildContext context,
    double initialChildSize,
  ) {
    if (contentKey.currentContext == null) {
      return 0.8;
    }

    final RenderBox? renderBox =
        contentKey.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return 0.8;
    }

    final double contentHeight = renderBox.size.height;
    final double screenHeight = MediaQuery.of(context).size.height;

    // AppBar + 핸들 + 여백을 고려한 전체 높이 계산
    const double appBarHeight = 56.0;
    const double handleHeight = 28.0; // 핸들 + 여백
    const double padding = 40.0; // 상하 여백

    final double totalHeight =
        contentHeight + appBarHeight + handleHeight + padding;
    final double calculatedRatio = totalHeight / screenHeight;

    return calculatedRatio.clamp(initialChildSize, 0.95);
  }
}
