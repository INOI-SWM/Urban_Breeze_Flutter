import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareGpxButton extends StatelessWidget {
  const ShareGpxButton({super.key, required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // iPad에서의 공유 시트 위치 지정을 위한 버튼 위치 계산
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Rect origin = box.localToGlobal(Offset.zero) & box.size;

        await _shareGpx(origin);
      },
      child: const Text('경로 공유 - gpx 파일로'),
    );
  }

  Future<void> _shareGpx(Rect origin) async {
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
}
