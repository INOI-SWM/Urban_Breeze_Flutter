import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static final AppShadows instance = const AppShadows._();

  final List<BoxShadow> normal = const <BoxShadow>[
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 1,
      spreadRadius: 0,
      color: Color.fromARGB(20, 0, 0, 0),
    ),
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
      color: Color.fromARGB(31, 0, 0, 0),
    ),
  ];

  final List<BoxShadow> emphasize = const <BoxShadow>[
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 1,
      spreadRadius: 0,
      color: Color.fromARGB(20, 0, 0, 0),
    ),
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
      color: Color.fromARGB(20, 0, 0, 0),
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
      color: Color.fromARGB(31, 0, 0, 0),
    ),
  ];

  final List<BoxShadow> strong = const <BoxShadow>[
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 4,
      spreadRadius: 0,
      color: Color.fromARGB(20, 0, 0, 0),
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
      color: Color.fromARGB(20, 0, 0, 0),
    ),
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: 0,
      color: Color.fromARGB(31, 0, 0, 0),
    ),
  ];

  final List<BoxShadow> heavy = const <BoxShadow>[
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 8,
      spreadRadius: 0,
      color: Color.fromARGB(20, 0, 0, 0),
    ),
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
      color: Color.fromARGB(20, 0, 0, 0),
    ),
    BoxShadow(
      offset: Offset(0, 16),
      blurRadius: 20,
      spreadRadius: 0,
      color: Color.fromARGB(31, 0, 0, 0),
    ),
  ];
}
