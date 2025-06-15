import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
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
  String userId,
  String routeId,
) async {
  final Rect origin = _getSharePositionOrigin(context);

  final String shareLink = await _getShareLink(userId, routeId);

  await SharePlus.instance.share(
    ShareParams(text: shareLink, sharePositionOrigin: origin),
  );
}

/// iPad에서 공유 시트가 버튼 근처에 나타나도록 위치 계산
Rect _getSharePositionOrigin(BuildContext context) {
  final RenderBox box = context.findRenderObject() as RenderBox;
  return box.localToGlobal(Offset.zero) & box.size;
}

Future<String> _getShareLink(String userId, String routeId) async {
  // TODO: 추후 실제 API 요청 로직으로 변경
  return 'https://ridingmate.app/share/route/$routeId?user=$userId&ref=mobile_share'; // 테스트용 URL (공유 시트 동작 확인용)
}
