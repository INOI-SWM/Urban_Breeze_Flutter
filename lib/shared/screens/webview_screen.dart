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
    this.onAuthFailure,
  });

  final String url;
  final String title;
  final VoidCallback? onAuthSuccess;
  final void Function(String? reason)? onAuthFailure;

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
                  Future<void>.microtask(() {
                    if (mounted) {
                      Navigator.of(context).pop(true);
                    }
                  });
                  return;
                }

                // Terra auth-failure URL 감지 시 실패 처리
                if (url.contains('auth-failure')) {
                  // URL에서 실패 사유 추출
                  final Uri uri = Uri.parse(url);
                  final String? reason = uri.queryParameters['reason'];

                  // 연동 실패 callback 실행
                  widget.onAuthFailure?.call(reason);

                  // 웹뷰 닫기
                  Future<void>.microtask(() {
                    if (mounted) {
                      Navigator.of(context).pop(false);
                    }
                  });
                  return;
                }

                setState(() {
                  isLoading = true;
                });
              },
              onPageFinished: (String url) {
                // onPageFinished에서도 체크 (혹시 onPageStarted에서 놓쳤을 경우)
                if (url.contains('auth-success')) {
                  widget.onAuthSuccess?.call();

                  Future<void>.microtask(() {
                    if (mounted) {
                      Navigator.of(context).pop(true);
                    }
                  });
                  return;
                }

                // auth-failure도 체크
                if (url.contains('auth-failure')) {
                  final Uri uri = Uri.parse(url);
                  final String? reason = uri.queryParameters['reason'];

                  widget.onAuthFailure?.call(reason);

                  Future<void>.microtask(() {
                    if (mounted) {
                      Navigator.of(context).pop(false);
                    }
                  });
                  return;
                }

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
