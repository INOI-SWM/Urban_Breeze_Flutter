import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/screens/webview_screen.dart';

class WebViewNavigation {
  static void navigateToWebView(
    BuildContext context, {
    required String url,
    required String title,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<Widget>(
        builder:
            (BuildContext context) => WebViewScreen(url: url, title: title),
      ),
    );
  }
}
