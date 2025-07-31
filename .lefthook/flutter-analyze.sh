#!/bin/sh
flutter analyze --fatal-warnings \
  || { echo "❌ Flutter analyze 에러로 push 중단됨"; exit 1; }