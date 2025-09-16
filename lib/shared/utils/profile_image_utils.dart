import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';

class ProfileImageUtils {
  /// 기본 프로필 아이콘 생성
  static Widget buildDefaultProfileIcon({
    required BuildContext context,
    double size = 40,
    Color? color,
    Color? backgroundColor,
  }) {
    final SemanticColors colors = context.semanticColor;
    return Container(
      color: backgroundColor ?? colors.fillNormal,
      child: Icon(
        Icons.person,
        size: size,
        color: color ?? colors.backgroundNormalNormal,
      ),
    );
  }

  /// 프로필 이미지 위젯 생성 (NetworkImage + 기본 아이콘)
  static Widget buildProfileImage({
    required BuildContext context,
    String? imageUrl,
    double size = 40,
    Color? iconColor,
    Color? backgroundColor,
    BoxFit fit = BoxFit.cover,
    Widget? defaultWidget,
  }) {
    // 기본 위젯이 제공되지 않으면 기본 아이콘 사용
    final Widget defaultIcon =
        defaultWidget ??
        buildDefaultProfileIcon(
          context: context,
          size: size,
          color: iconColor,
          backgroundColor: backgroundColor,
        );

    // 이미지 URL이 없거나 비어있으면 기본 아이콘 반환
    if (imageUrl == null || imageUrl.isEmpty) {
      return defaultIcon;
    }

    // 유효하지 않은 URL 체크 (file://, 빈 문자열 등)
    if (imageUrl.startsWith('file://') || !imageUrl.startsWith('http')) {
      return defaultIcon;
    }

    // NetworkImage로 이미지 표시
    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        // 이미지 로드 실패 시 기본 아이콘 표시
        return defaultIcon;
      },
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
      ) {
        // 로딩 중일 때 로딩 인디케이터 표시
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value:
                loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
          ),
        );
      },
    );
  }

  /// CircleAvatar 형태의 프로필 이미지 생성
  static Widget buildCircleAvatarProfileImage({
    required BuildContext context,
    String? imageUrl,
    double radius = 40,
    Color? iconColor,
    Color? backgroundColor,
    Widget? defaultWidget,
  }) {
    final double size = radius * 2;
    final Widget defaultIcon =
        defaultWidget ??
        buildDefaultProfileIcon(
          context: context,
          size: size * 0.67, // CircleAvatar 크기의 2/3 정도
          color: iconColor,
          backgroundColor: backgroundColor,
        );

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage:
          _isValidImageUrl(imageUrl) ? NetworkImage(imageUrl!) : null,
      child: _isValidImageUrl(imageUrl) ? null : defaultIcon,
    );
  }

  /// ClipOval 형태의 프로필 이미지 생성
  static Widget buildClipOvalProfileImage({
    required BuildContext context,
    String? imageUrl,
    double size = 40,
    Color? iconColor,
    Color? backgroundColor,
    Widget? defaultWidget,
    BoxDecoration? decoration,
  }) {
    final Widget defaultIcon =
        defaultWidget ??
        buildDefaultProfileIcon(
          context: context,
          size: size * 0.67,
          color: iconColor,
          backgroundColor: backgroundColor,
        );

    return Container(
      width: size,
      height: size,
      decoration:
          decoration ??
          BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
      child: ClipOval(
        child: buildProfileImage(
          context: context,
          imageUrl: imageUrl,
          size: size,
          iconColor: iconColor,
          backgroundColor: backgroundColor,
          defaultWidget: defaultIcon,
        ),
      ),
    );
  }

  /// 이미지 URL 유효성 검사
  static bool _isValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    if (imageUrl.startsWith('file://')) return false;
    if (!imageUrl.startsWith('http')) return false;
    return true;
  }
}
