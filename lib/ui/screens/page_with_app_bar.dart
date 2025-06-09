import 'package:flutter/material.dart';

abstract class PageWithAppBar extends Widget {
  const PageWithAppBar({super.key});

  PreferredSizeWidget? getAppBar(BuildContext context);
}
