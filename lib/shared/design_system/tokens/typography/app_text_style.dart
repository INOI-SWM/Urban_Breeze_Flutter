import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style_constants.dart';

extension TextStyleExtensions on TextStyle {
  TextStyle withPercentageLetterSpacing(double percentage) {
    if (fontSize == null) {
      debugPrint(
        'Warning: Cannot calculate letterSpacing without a fontSize. Returning letterSpacing: 0.',
      );
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
    fontWeight: FontWeight.bold, // 혹은 FontWeight.w700
    fontSize: AppTextStyleConstants.display1Size,
    height: AppTextStyleConstants.display1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.display1LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.display1Size,
    height: AppTextStyleConstants.display1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.display1LetterSpacing);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal, // 혹은 FontWeight.w400
    fontSize: AppTextStyleConstants.display1Size,
    height: AppTextStyleConstants.display1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.display1LetterSpacing);
}

class Display2 {
  const Display2._();
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.display2Size,
    height: AppTextStyleConstants.display2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.display2LetterSpacing);
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: AppTextStyleConstants.display2Size,
    height: AppTextStyleConstants.display2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.display2LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.display2Size,
    height: AppTextStyleConstants.display2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.display2LetterSpacing);
}

class Title1 {
  const Title1._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: AppTextStyleConstants.title1Size,
    height: AppTextStyleConstants.title1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.title1LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.title1Size,
    height: AppTextStyleConstants.title1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.title1LetterSpacing);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.title1Size,
    height: AppTextStyleConstants.title1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.title1LetterSpacing);
}

class Title2 {
  const Title2._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: AppTextStyleConstants.title2Size,
    height: AppTextStyleConstants.title2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.title2LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.title2Size,
    height: AppTextStyleConstants.title2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.title2LetterSpacing);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.title2Size,
    height: AppTextStyleConstants.title2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.title2LetterSpacing);
}

class Title3 {
  const Title3._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: AppTextStyleConstants.title3Size,
    height: AppTextStyleConstants.title3LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.title3LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.title3Size,
    height: AppTextStyleConstants.title3LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.title3LetterSpacing);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.title3Size,
    height: AppTextStyleConstants.title3LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.title3LetterSpacing);
}

class Heading1 {
  const Heading1._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.heading1Size,
    height: AppTextStyleConstants.heading1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.heading1LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.heading1Size,
    height: AppTextStyleConstants.heading1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.heading1LetterSpacing);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.heading1Size,
    height: AppTextStyleConstants.heading1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.heading1LetterSpacing);
}

class Heading2 {
  const Heading2._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.heading2Size,
    height: AppTextStyleConstants.heading2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.heading2LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.heading2Size,
    height: AppTextStyleConstants.heading2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.heading2LetterSpacing);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.heading2Size,
    height: AppTextStyleConstants.heading2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.heading2LetterSpacing);
}

class Headline1 {
  const Headline1._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.headline1Size,
    height: AppTextStyleConstants.headline1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.headline1LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.headline1Size,
    height: AppTextStyleConstants.headline1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.headline1LetterSpacing);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.headline1Size,
    height: AppTextStyleConstants.headline1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.headline1LetterSpacing);
}

class Headline2 {
  const Headline2._();
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.headline2Size,
    height: AppTextStyleConstants.headline2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.headline2LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.headline2Size,
    height: AppTextStyleConstants.headline2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.headline2LetterSpacing);
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.headline2Size,
    height: AppTextStyleConstants.headline2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.headline2LetterSpacing);
}

class Body1 {
  const Body1._();
  TextStyle get normalRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.body1Size,
    height: AppTextStyleConstants.body1NormalLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body1LetterSpacing);
  TextStyle get normalMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.body1Size,
    height: AppTextStyleConstants.body1NormalLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body1LetterSpacing);
  TextStyle get normalBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.body1Size,
    height: AppTextStyleConstants.body1NormalLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body1LetterSpacing);
  TextStyle get readingRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.body1Size,
    height: AppTextStyleConstants.body1ReadingLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body1LetterSpacing);
  TextStyle get readingMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.body1Size,
    height: AppTextStyleConstants.body1ReadingLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body1LetterSpacing);
  TextStyle get readingBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.body1Size,
    height: AppTextStyleConstants.body1ReadingLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body1LetterSpacing);
}

class Body2 {
  const Body2._();
  TextStyle get normalRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.body2Size,
    height: AppTextStyleConstants.body2NormalLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body2LetterSpacing);
  TextStyle get normalMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.body2Size,
    height: AppTextStyleConstants.body2NormalLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body2LetterSpacing);
  TextStyle get normalBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.body2Size,
    height: AppTextStyleConstants.body2NormalLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body2LetterSpacing);
  TextStyle get readingRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.body2Size,
    height: AppTextStyleConstants.body2ReadingLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body2LetterSpacing);
  TextStyle get readingMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.body2Size,
    height: AppTextStyleConstants.body2ReadingLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body2LetterSpacing);
  TextStyle get readingBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.body2Size,
    height: AppTextStyleConstants.body2ReadingLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.body2LetterSpacing);
}

class Label1 {
  const Label1._();
  TextStyle get normalBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.label1Size,
    height: AppTextStyleConstants.label1NormalLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.label1LetterSpacing);
  TextStyle get normalMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.label1Size,
    height: AppTextStyleConstants.label1NormalLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.label1LetterSpacing);
  TextStyle get normalRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.label1Size,
    height: AppTextStyleConstants.label1NormalLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.label1LetterSpacing);
  TextStyle get readingBold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.label1Size,
    height: AppTextStyleConstants.label1ReadingLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.label1LetterSpacing);
  TextStyle get readingMedium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.label1Size,
    height: AppTextStyleConstants.label1ReadingLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.label1LetterSpacing);
  TextStyle get readingRegular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.label1Size,
    height: AppTextStyleConstants.label1ReadingLineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.label1LetterSpacing);
}

class Label2 {
  const Label2._();
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.label2Size,
    height: AppTextStyleConstants.label2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.label2LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.label2Size,
    height: AppTextStyleConstants.label2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.label2LetterSpacing);
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.label2Size,
    height: AppTextStyleConstants.label2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.label2LetterSpacing);
}

class Caption1 {
  const Caption1._();
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.caption1Size,
    height: AppTextStyleConstants.caption1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.caption1LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.caption1Size,
    height: AppTextStyleConstants.caption1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.caption1LetterSpacing);
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.caption1Size,
    height: AppTextStyleConstants.caption1LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.caption1LetterSpacing);
}

class Caption2 {
  const Caption2._();
  TextStyle get regular => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: AppTextStyleConstants.caption2Size,
    height: AppTextStyleConstants.caption2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.caption2LetterSpacing);
  TextStyle get medium => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: AppTextStyleConstants.caption2Size,
    height: AppTextStyleConstants.caption2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.caption2LetterSpacing);
  TextStyle get bold => const TextStyle(
    fontFamily: AppTextStyles._fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: AppTextStyleConstants.caption2Size,
    height: AppTextStyleConstants.caption2LineHeight,
  ).withPercentageLetterSpacing(AppTextStyleConstants.caption2LetterSpacing);
}
