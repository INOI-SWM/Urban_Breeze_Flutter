import 'package:flutter/material.dart';

extension TextStyleExtensions on TextStyle {
  TextStyle withPercentageLetterSpacing(double percentage) {
    if (fontSize == null) {
      debugPrint('Warning: Cannot calculate letterSpacing without a fontSize.');
      return copyWith(letterSpacing: 0);
    }
    return copyWith(letterSpacing: fontSize! * (percentage / 100));
  }
}

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Pretendard JP';

  static const Display1 display1 = Display1._();

  static const Display2 display2 = Display2._();

  static const Title1 title1 = Title1._();

  static const Title2 title2 = Title2._();

  static const Title3 title3 = Title3._();

  static const Heading1 heading1 = Heading1._();

  static const Heading2 heading2 = Heading2._();

  static const Headline1 headline1 = Headline1._();

  static const Headline2 headline2 = Headline2._();

  static const Body1 body1 = Body1._();

  static const Body2 body2 = Body2._();

  static const Label1 label1 = Label1._();

  static const Label2 label2 = Label2._();

  static const Caption1 caption1 = Caption1._();

  static const Caption2 caption2 = Caption2._();
}

class Display1 {
  const Display1._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 56,
  ).withPercentageLetterSpacing(-3.190000057220459);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 56,
  ).withPercentageLetterSpacing(-3.190000057220459);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 56,
  ).withPercentageLetterSpacing(-3.190000057220459);
}

class Display2 {
  const Display2._();
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 40,
  ).withPercentageLetterSpacing(-2.819999933242798);
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 40,
  ).withPercentageLetterSpacing(-2.819999933242798);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 40,
  ).withPercentageLetterSpacing(-2.819999933242798);
}

class Title1 {
  const Title1._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 36,
  ).withPercentageLetterSpacing(-2.700000047683716);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 36,
  ).withPercentageLetterSpacing(-2.700000047683716);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 36,
  ).withPercentageLetterSpacing(-2.700000047683716);
}

class Title2 {
  const Title2._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 28,
  ).withPercentageLetterSpacing(-2.359999895095825);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 28,
  ).withPercentageLetterSpacing(-2.359999895095825);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 28,
  ).withPercentageLetterSpacing(-2.359999895095825);
}

class Title3 {
  const Title3._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 24,
  ).withPercentageLetterSpacing(-2.299999952316284);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 24,
  ).withPercentageLetterSpacing(-2.299999952316284);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 24,
  ).withPercentageLetterSpacing(-2.299999952316284);
}

class Heading1 {
  const Heading1._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 22,
  ).withPercentageLetterSpacing(-1.940000057220459);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 22,
  ).withPercentageLetterSpacing(-1.940000057220459);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 22,
  ).withPercentageLetterSpacing(-1.940000057220459);
}

class Heading2 {
  const Heading2._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20,
  ).withPercentageLetterSpacing(-1.2000000476837158);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 20,
  ).withPercentageLetterSpacing(-1.2000000476837158);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 20,
  ).withPercentageLetterSpacing(-1.2000000476837158);
}

class Headline1 {
  const Headline1._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18,
  ).withPercentageLetterSpacing(-0.019999999552965164);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 18,
  ).withPercentageLetterSpacing(-0.019999999552965164);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 18,
  ).withPercentageLetterSpacing(0);
}

class Headline2 {
  const Headline2._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 17,
  ).withPercentageLetterSpacing(0);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 17,
  ).withPercentageLetterSpacing(0);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 17,
  ).withPercentageLetterSpacing(0);
}

class Body1 {
  const Body1._();
  TextStyle get normalRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 16,
  ).withPercentageLetterSpacing(0.5699999928474426);
  TextStyle get normalMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  ).withPercentageLetterSpacing(0.5699999928474426);
  TextStyle get normalBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  ).withPercentageLetterSpacing(0.5699999928474426);
  TextStyle get readingRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 16,
  ).withPercentageLetterSpacing(0.5699999928474426);
  TextStyle get readingMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  ).withPercentageLetterSpacing(0.5699999928474426);
  TextStyle get readingBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  ).withPercentageLetterSpacing(0.5699999928474426);
}

class Body2 {
  const Body2._();
  TextStyle get normalRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 15,
  ).withPercentageLetterSpacing(0.9599999785423279);
  TextStyle get normalMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 15,
  ).withPercentageLetterSpacing(0.9599999785423279);
  TextStyle get normalBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 15,
  ).withPercentageLetterSpacing(0.9599999785423279);
  TextStyle get readingRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 15,
  ).withPercentageLetterSpacing(0.9599999785423279);
  TextStyle get readingMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 15,
  ).withPercentageLetterSpacing(0.9599999785423279);
  TextStyle get readingBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 15,
  ).withPercentageLetterSpacing(0.9599999785423279);
}

class Label1 {
  const Label1._();
  TextStyle get normalBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  ).withPercentageLetterSpacing(1.4500000476837158);
  TextStyle get normalMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  ).withPercentageLetterSpacing(1.4500000476837158);
  TextStyle get normalRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 14,
  ).withPercentageLetterSpacing(1.4500000476837158);
  TextStyle get readingBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  ).withPercentageLetterSpacing(1.4500000476837158);
  TextStyle get readingMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  ).withPercentageLetterSpacing(1.4500000476837158);
  TextStyle get readingRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 14,
  ).withPercentageLetterSpacing(1.4500000476837158);
}

class Label2 {
  const Label2._();
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 13,
  ).withPercentageLetterSpacing(1.940000057220459);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 13,
  ).withPercentageLetterSpacing(1.940000057220459);
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 13,
  ).withPercentageLetterSpacing(1.940000057220459);
}

class Caption1 {
  const Caption1._();
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 12,
  ).withPercentageLetterSpacing(2.5199999809265137);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12,
  ).withPercentageLetterSpacing(2.5199999809265137);
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
  ).withPercentageLetterSpacing(2.5199999809265137);
}

class Caption2 {
  const Caption2._();
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 11,
  ).withPercentageLetterSpacing(3.109999895095825);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 11,
  ).withPercentageLetterSpacing(3.109999895095825);
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 11,
  ).withPercentageLetterSpacing(3.109999895095825);
}
