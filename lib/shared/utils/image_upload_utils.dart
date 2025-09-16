import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageUploadUtils {
  /// 파일 크기 검증
  static void validateFileSize(File imageFile, {int maxSizeInMB = 20}) {
    final int fileSize = imageFile.lengthSync();
    final int maxFileSize = maxSizeInMB * 1024 * 1024;

    if (fileSize > maxFileSize) {
      throw Exception('파일 크기가 너무 큽니다. ${maxSizeInMB}MB 이하의 이미지를 선택해주세요.');
    }
  }

  /// 파일 확장자에 따른 MIME 타입 반환
  static String getMimeTypeFromExtension(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'tiff':
        return 'image/tiff';
      default:
        return 'image/jpeg'; // 기본값
    }
  }

  /// 파일에서 확장자 추출
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// MultipartFile 생성 (이미지 업로드용)
  static Future<http.MultipartFile> createImageMultipartFile(
    File imageFile,
    String fieldName, {
    int maxSizeInMB = 20,
  }) async {
    // 파일 크기 검증
    validateFileSize(imageFile, maxSizeInMB: maxSizeInMB);

    // 파일 확장자와 MIME 타입 결정
    final String fileExtension = getFileExtension(imageFile.path);
    final String mimeType = getMimeTypeFromExtension(fileExtension);

    // MultipartFile 생성
    return await http.MultipartFile.fromPath(
      fieldName,
      imageFile.path,
      contentType: MediaType.parse(mimeType),
    );
  }

  /// 지원되는 이미지 형식인지 검증
  static bool isSupportedImageType(String mimeType) {
    const List<String> supportedTypes = <String>[
      'image/jpeg',
      'image/png',
      'image/webp',
      'image/gif',
    ];
    return supportedTypes.contains(mimeType);
  }

  /// 파일에서 MIME 타입 추출 및 검증
  static String getValidatedMimeType(File imageFile) {
    final String fileExtension = getFileExtension(imageFile.path);
    final String mimeType = getMimeTypeFromExtension(fileExtension);

    if (!isSupportedImageType(mimeType)) {
      throw Exception('지원하지 않는 이미지 형식입니다. JPG, PNG, WebP, GIF 형식을 사용해주세요.');
    }

    return mimeType;
  }
}
