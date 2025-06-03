import 'package:flutter/material.dart';
import 'package:ridingmate/design_system/atomic/atomic_colors.dart';

abstract class SemanticColors {
  Color get primaryNormal;
  Color get primaryStrong;
  Color get primaryHeavy;

  Color get labelNormal;
  Color get labelStrong;
  Color get labelNeutral;
  Color get labelAlternative;
  Color get labelAssistive;
  Color get labelDisable;

  Color get backgroundNormalNormal;
  Color get backgroundNormalAlternative;
  Color get backgroundElevatedNormal;
  Color get backgroundElevatedAlternative;

  Color get interactionInactive;
  Color get interactionDisable;

  Color get lineNormalNormal;
  Color get lineNormalNeutral;
  Color get lineNormalAlternative;
  Color get lineNormalStrong;
  Color get lineSolidNormal;
  Color get lineSolidNeutral;
  Color get lineSolidAlternative;

  Color get fillNormal;
  Color get fillStrong;
  Color get fillAlternative;

  Color get statusPositive;
  Color get statusCautionary;
  Color get statusNegative;

  Color get staticWhite;
  Color get staticBlack;

  Color get accentBackgroundLime;
  Color get accentBackgroundCyan;
  Color get accentBackgroundLightBlue;
  Color get accentBackgroundViolet;
  Color get accentBackgroundPink;

  Color get materialDimmer;

  Color get inversePrimary;
  Color get inverseBackground;
  Color get inverseLabel;
}

class LightSemanticColors implements SemanticColors {
  const LightSemanticColors();

  @override
  Color get primaryNormal => Atomic.instance.blue.c50;
  @override
  Color get primaryStrong => Atomic.instance.blue.c45;
  @override
  Color get primaryHeavy => Atomic.instance.blue.c40;

  @override
  Color get labelNormal => Atomic.instance.coolNeutral.c10;
  @override
  Color get labelStrong => Atomic.instance.common.c0;
  @override
  Color get labelNeutral => Atomic.instance.coolNeutral.c22.withAlpha(224);
  @override
  Color get labelAlternative => Atomic.instance.coolNeutral.c25.withAlpha(156);
  @override
  Color get labelAssistive => Atomic.instance.coolNeutral.c25.withAlpha(71);
  @override
  Color get labelDisable => Atomic.instance.coolNeutral.c25.withAlpha(41);

  @override
  Color get backgroundNormalNormal => Atomic.instance.common.c100;
  @override
  Color get backgroundNormalAlternative => Atomic.instance.coolNeutral.c99;
  @override
  Color get backgroundElevatedNormal => Atomic.instance.common.c100;
  @override
  Color get backgroundElevatedAlternative => Atomic.instance.coolNeutral.c99;

  @override
  Color get interactionInactive => Atomic.instance.coolNeutral.c70;
  @override
  Color get interactionDisable => Atomic.instance.coolNeutral.c98;

  @override
  Color get lineNormalNormal => Atomic.instance.coolNeutral.c50.withAlpha(56);
  @override
  Color get lineNormalNeutral => Atomic.instance.coolNeutral.c50.withAlpha(41);
  @override
  Color get lineNormalAlternative =>
      Atomic.instance.coolNeutral.c50.withAlpha(20);
  @override
  Color get lineNormalStrong => Atomic.instance.coolNeutral.c50.withAlpha(133);
  @override
  Color get lineSolidNormal => Atomic.instance.coolNeutral.c96;
  @override
  Color get lineSolidNeutral => Atomic.instance.coolNeutral.c97;
  @override
  Color get lineSolidAlternative => Atomic.instance.coolNeutral.c98;

  @override
  Color get fillNormal => Atomic.instance.coolNeutral.c50.withAlpha(20);
  @override
  Color get fillStrong => Atomic.instance.coolNeutral.c50.withAlpha(41);
  @override
  Color get fillAlternative => Atomic.instance.coolNeutral.c50.withAlpha(13);

  @override
  Color get statusPositive => Atomic.instance.green.c50;
  @override
  Color get statusCautionary => Atomic.instance.orange.c50;
  @override
  Color get statusNegative => Atomic.instance.red.c50;

  @override
  Color get staticWhite => Atomic.instance.common.c100;
  @override
  Color get staticBlack => Atomic.instance.common.c0;

  @override
  Color get accentBackgroundLime => Atomic.instance.lime.c50;
  @override
  Color get accentBackgroundCyan => Atomic.instance.cyan.c50;
  @override
  Color get accentBackgroundLightBlue => Atomic.instance.lightBlue.c50;
  @override
  Color get accentBackgroundViolet => Atomic.instance.violet.c50;
  @override
  Color get accentBackgroundPink => Atomic.instance.pink.c50;

  @override
  Color get materialDimmer => Atomic.instance.coolNeutral.c10.withAlpha(133);

  @override
  Color get inversePrimary => Atomic.instance.blue.c60;
  @override
  Color get inverseBackground => Atomic.instance.coolNeutral.c15;
  @override
  Color get inverseLabel => Atomic.instance.coolNeutral.c99;
}

class DarkSemanticColors implements SemanticColors {
  const DarkSemanticColors();

  @override
  Color get primaryNormal => Atomic.instance.blue.c60;
  @override
  Color get primaryStrong => Atomic.instance.blue.c55;
  @override
  Color get primaryHeavy => Atomic.instance.blue.c50;

  @override
  Color get labelNormal => Atomic.instance.coolNeutral.c99;
  @override
  Color get labelStrong => Atomic.instance.common.c100;
  @override
  Color get labelNeutral => Atomic.instance.coolNeutral.c90.withAlpha(224);
  @override
  Color get labelAlternative => Atomic.instance.coolNeutral.c80.withAlpha(156);
  @override
  Color get labelAssistive => Atomic.instance.coolNeutral.c80.withAlpha(71);
  @override
  Color get labelDisable => Atomic.instance.coolNeutral.c70.withAlpha(41);

  @override
  Color get backgroundNormalNormal => Atomic.instance.coolNeutral.c15;
  @override
  Color get backgroundNormalAlternative => Atomic.instance.coolNeutral.c5;
  @override
  Color get backgroundElevatedNormal => Atomic.instance.coolNeutral.c17;
  @override
  Color get backgroundElevatedAlternative => Atomic.instance.coolNeutral.c7;

  @override
  Color get interactionInactive => Atomic.instance.coolNeutral.c40;
  @override
  Color get interactionDisable => Atomic.instance.coolNeutral.c22;

  @override
  Color get lineNormalNormal => Atomic.instance.coolNeutral.c50.withAlpha(82);
  @override
  Color get lineNormalNeutral => Atomic.instance.coolNeutral.c50.withAlpha(71);
  @override
  Color get lineNormalAlternative =>
      Atomic.instance.coolNeutral.c50.withAlpha(56);
  @override
  Color get lineNormalStrong => Atomic.instance.coolNeutral.c90.withAlpha(133);
  @override
  Color get lineSolidNormal => Atomic.instance.coolNeutral.c25;
  @override
  Color get lineSolidNeutral => Atomic.instance.coolNeutral.c23;
  @override
  Color get lineSolidAlternative => Atomic.instance.coolNeutral.c22;

  @override
  Color get fillNormal => Atomic.instance.coolNeutral.c50.withAlpha(56);
  @override
  Color get fillStrong => Atomic.instance.coolNeutral.c50.withAlpha(71);
  @override
  Color get fillAlternative => Atomic.instance.coolNeutral.c50.withAlpha(31);

  @override
  Color get statusPositive => Atomic.instance.green.c60;
  @override
  Color get statusCautionary => Atomic.instance.orange.c60;
  @override
  Color get statusNegative => Atomic.instance.red.c60;

  @override
  Color get staticWhite => Atomic.instance.common.c100;
  @override
  Color get staticBlack => Atomic.instance.common.c0;

  @override
  Color get accentBackgroundLime => Atomic.instance.lime.c60;
  @override
  Color get accentBackgroundCyan => Atomic.instance.cyan.c60;
  @override
  Color get accentBackgroundLightBlue => Atomic.instance.lightBlue.c60;
  @override
  Color get accentBackgroundViolet => Atomic.instance.violet.c60;
  @override
  Color get accentBackgroundPink => Atomic.instance.pink.c60;

  @override
  Color get materialDimmer => Atomic.instance.coolNeutral.c10.withAlpha(189);

  @override
  Color get inversePrimary => Atomic.instance.blue.c50;
  @override
  Color get inverseBackground => Atomic.instance.common.c100;
  @override
  Color get inverseLabel => Atomic.instance.coolNeutral.c10;
}
