import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({
    super.key,
    required this.url,
    this.title = '웹페이지',
    this.onAuthSuccess,
  });

  final String url;
  final String title;
  final VoidCallback? onAuthSuccess;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // 로딩 진행률 업데이트
              },
              onPageStarted: (String url) {
                // Terra auth-success URL 감지 시 자동으로 웹뷰 닫기
                if (url.contains('auth-success')) {
                  // 연동 성공 callback 실행
                  widget.onAuthSuccess?.call();
                  // 웹뷰 닫기
                  if (mounted) {
                    Navigator.of(context).pop(true);
                  }
                  return;
                }

                setState(() {
                  isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false;
                });
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      appBar: CustomAppBar(
        centerTitle: true,
        title: widget.title,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: controller),
          if (isLoading) const Center(child: AppLoadingIndicator()),
        ],
      ),
    );
  }
}
