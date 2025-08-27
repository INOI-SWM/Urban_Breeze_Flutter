import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/navigation/navigation_scaffold.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class ConsentScreen extends ConsumerWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(centerTitle: true, title: '이용약관 동의'),
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Center(
                child: Text('이용약관 동의 화면', style: AppTextStyles.heading2.bold),
              ),
            ),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 동의 완료 후 홈화면으로 이동
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<Widget>(
                        builder:
                            (BuildContext context) =>
                                const NavigationScaffold(),
                      ),
                    );
                  },
                  child: const Text('동의 완료'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
