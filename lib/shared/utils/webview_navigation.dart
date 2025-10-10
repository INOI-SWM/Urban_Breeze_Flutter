import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/screens/webview_screen.dart';

class WebViewNavigation {
  static Future<bool?> navigateToWebView(
    BuildContext context, {
    required String url,
    required String title,
    VoidCallback? onAuthSuccess,
    void Function(String? reason)? onAuthFailure,
  }) async {
    return await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder:
            (BuildContext context) => WebViewScreen(
              url: url,
              title: title,
              onAuthSuccess: onAuthSuccess,
              onAuthFailure: onAuthFailure,
            ),
      ),
    );
  }
}
