import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('홈'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => FirebaseCrashlytics.instance.crash(),
            child: const Text('Crashlytics 강제 크래시'),
          ),
        ],
      ),
    );
  }
}
