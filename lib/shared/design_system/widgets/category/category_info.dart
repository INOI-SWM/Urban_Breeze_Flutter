import 'package:flutter/material.dart';

class CategoryInfo {
  const CategoryInfo({
    required this.id,
    required this.title,
    required this.displayText,
    this.leftIcon,
    this.rightIcon,
  });

  final String id; // 식별자
  final String title; // 원본 제목
  final String displayText; // 화면에 표시될 텍스트

  final IconData? leftIcon;
  final IconData? rightIcon;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryInfo &&
        other.id == id &&
        other.title == title &&
        other.displayText == displayText;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, displayText);
  }

  @override
  String toString() {
    return 'CategoryInfo(id: $id, title: $title, displayText: $displayText)';
  }
}
