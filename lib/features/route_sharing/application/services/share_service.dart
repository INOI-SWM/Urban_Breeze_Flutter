import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ridingmate/core/result/app_result.dart';
import 'package:ridingmate/features/route_sharing/di/route_sharing_providers.dart';
import 'package:ridingmate/features/route_sharing/domain/entities/route_share_link.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareGpxFile(BuildContext context, String assetPath) async {
  final Rect origin = _getSharePositionOrigin(context);

  final ByteData data = await rootBundle.load(assetPath);
  final Directory tempDir = await getTemporaryDirectory();
  final String fileName = assetPath.split('/').last;
  final File file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(data.buffer.asUint8List());

  await SharePlus.instance.share(
    ShareParams(
      text: '라이딩 경로 GPX 파일입니다.',
      files: <XFile>[XFile(file.path, mimeType: 'application/gpx+xml')],
      sharePositionOrigin: origin,
    ),
  );
}

Future<void> shareRouteLink(
  BuildContext context,
  WidgetRef ref,
  String routeId,
) async {
  final Rect origin = _getSharePositionOrigin(context);

  final AppResult<RouteShareLink> result = await ref
      .read(getRouteShareLinkUseCaseProvider)
      .execute(routeId);
  if (result.isFailure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.exceptionOrNull?.message ?? '공유 링크 생성 실패')),
    );
    return;
  }

  final RouteShareLink link = result.dataOrNull!;
  await SharePlus.instance.share(
    ShareParams(text: link.url, sharePositionOrigin: origin),
  );
}

/// iPad에서 공유 시트가 버튼 근처에 나타나도록 위치 계산
Rect _getSharePositionOrigin(BuildContext context) {
  final RenderBox box = context.findRenderObject() as RenderBox;
  return box.localToGlobal(Offset.zero) & box.size;
}
