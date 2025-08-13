import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';

class MyRouteDetailScreen extends StatelessWidget {
  const MyRouteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      body: const Center(child: Text('내용 준비 중')),
    );
  }
}
