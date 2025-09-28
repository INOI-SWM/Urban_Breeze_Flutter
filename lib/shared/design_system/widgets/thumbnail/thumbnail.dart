import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';

enum ThumbnailRatio {
  square,
  r5_4,
  r4_3,
  r3_2,
  r16_10,
  golden,
  r16_9,
  r2_1,
  r21_9,
  r4_5,
  r3_4,
  r2_3,
  r10_16,
  invGolden,
  r9_16,
  r1_2,
  r9_21,
}

enum ThumbnailSourceType { network, asset, file }

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    super.key,
    required this.path,
    required this.ratio,
    required this.sourceType,
    this.fit = BoxFit.cover,
    this.hasRadius = false,
  });

  final String path;
  final ThumbnailRatio ratio;
  final ThumbnailSourceType sourceType;
  final BoxFit fit;
  final bool hasRadius;

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget = switch (sourceType) {
      ThumbnailSourceType.asset => Image.asset(path, fit: fit),
      ThumbnailSourceType.file => Image.file(File(path), fit: fit),
      ThumbnailSourceType.network => CachedNetworkImage(
        imageUrl: path,
        fit: fit,
        placeholder: (BuildContext context, String url) {
          return const Center(child: AppLoadingIndicator());
        },
        errorWidget: (BuildContext context, String url, dynamic error) {
          return const Center(child: Icon(Icons.broken_image));
        },
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        cacheManager: CacheManager(
          Config(
            'thumbnails',
            stalePeriod: const Duration(days: 3), // 3일간 캐시 유지
            maxNrOfCacheObjects: 200, // 최대 200개 썸네일 캐시
          ),
        ),
      ),
    };

    return AspectRatio(
      aspectRatio: _getAspectRatio(),
      child: ClipRRect(
        borderRadius:
            hasRadius
                ? const BorderRadius.all(Radius.circular(12))
                : BorderRadius.zero,
        child: imageWidget,
      ),
    );
  }

  double _getAspectRatio() {
    switch (ratio) {
      case ThumbnailRatio.square:
        return 1 / 1;
      case ThumbnailRatio.r5_4:
        return 5 / 4;
      case ThumbnailRatio.r4_3:
        return 4 / 3;
      case ThumbnailRatio.r3_2:
        return 3 / 2;
      case ThumbnailRatio.r16_10:
        return 16 / 10;
      case ThumbnailRatio.golden:
        return 1.618 / 1;
      case ThumbnailRatio.r16_9:
        return 16 / 9;
      case ThumbnailRatio.r2_1:
        return 2 / 1;
      case ThumbnailRatio.r21_9:
        return 21 / 9;
      case ThumbnailRatio.r4_5:
        return 4 / 5;
      case ThumbnailRatio.r3_4:
        return 3 / 4;
      case ThumbnailRatio.r2_3:
        return 2 / 3;
      case ThumbnailRatio.r10_16:
        return 10 / 16;
      case ThumbnailRatio.invGolden:
        return 1 / 1.618;
      case ThumbnailRatio.r9_16:
        return 9 / 16;
      case ThumbnailRatio.r1_2:
        return 1 / 2;
      case ThumbnailRatio.r9_21:
        return 9 / 21;
    }
  }
}
