import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';

class ProfileImageUtils {
  // 공통 CacheManager 인스턴스
  static final CacheManager _profileImageCacheManager = CacheManager(
    Config(
      'profile_images',
      stalePeriod: const Duration(days: 7), // 7일간 캐시 유지
      maxNrOfCacheObjects: 100, // 최대 100개 이미지 캐시
    ),
  );

  /// 기본 프로필 아이콘 생성
  static Widget buildDefaultProfileIcon({
    required BuildContext context,
    double size = 40,
    Color? color,
    Color? backgroundColor,
  }) {
    final SemanticColors colors = context.semanticColor;
    final double iconSize = size * 0.5; // 전체 크기의 1/2

    return Container(
      color: backgroundColor ?? colors.fillStrong,
      child: Icon(
        Icons.person,
        size: iconSize,
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

    // CachedNetworkImage로 이미지 표시 (깜빡임 없는 로딩)
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (BuildContext context, String url) {
        // 캐시가 있어도 placeholder가 보이지 않도록 null 반환
        return const SizedBox.shrink();
      },
      errorWidget: (BuildContext context, String url, dynamic error) {
        // 이미지 로드 실패 시 기본 아이콘 표시
        return defaultIcon;
      },
      fadeInDuration: Duration.zero, // 페이드 인 애니메이션 제거
      fadeOutDuration: Duration.zero, // 페이드 아웃 애니메이션 제거
      cacheManager: _profileImageCacheManager,
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
          size: size, // 전체 크기 사용 (내부에서 1/2로 계산됨)
          color: iconColor,
          backgroundColor: backgroundColor,
        );

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.transparent,
      child:
          _isValidImageUrl(imageUrl)
              ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholder:
                      (BuildContext context, String url) =>
                          const SizedBox.shrink(),
                  errorWidget:
                      (BuildContext context, String url, dynamic error) =>
                          defaultIcon,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  cacheManager: _profileImageCacheManager,
                ),
              )
              : defaultIcon,
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
          size: size, // 전체 크기 사용 (내부에서 1/2로 계산됨)
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
        child:
            _isValidImageUrl(imageUrl)
                ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholder:
                      (BuildContext context, String url) =>
                          const SizedBox.shrink(),
                  errorWidget:
                      (BuildContext context, String url, dynamic error) =>
                          defaultIcon,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  cacheManager: _profileImageCacheManager,
                )
                : defaultIcon,
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
