import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';

class ProfileImageEditButton extends StatelessWidget {
  const ProfileImageEditButton({
    super.key,
    required this.imageUrl,
    this.onPressed,
  });

  final String imageUrl;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: GestureDetector(
          onTap: onPressed,
          child: Stack(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.backgroundElevatedNormal,
                  border: Border.all(
                    color: colors.lineNormalAlternative,
                    width: 1,
                  ),
                ),
                child: ClipOval(child: _buildImage()),
              ),

              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primaryNormal,
                    border: Border.all(
                      color: colors.backgroundNormalNormal,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 12,
                    color: colors.staticWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    // 이미지 URL 유효성 검사
    if (imageUrl.isEmpty ||
        !imageUrl.startsWith('http') ||
        imageUrl.startsWith('file://')) {
      // 기본 아이콘 표시
      return Icon(Icons.person, size: 40, color: Colors.grey[400]);
    }

    // 유효한 네트워크 이미지 표시
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        // 이미지 로드 실패 시 기본 아이콘 표시
        return Icon(Icons.person, size: 40, color: Colors.grey[400]);
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
}
