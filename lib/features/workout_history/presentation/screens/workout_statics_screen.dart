import 'package:flutter/material.dart';

class WorkoutStaticsScreen extends StatelessWidget {
  const WorkoutStaticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(children: <Widget>[Text('통계')]),
    );
  }
}
