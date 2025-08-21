#!/bin/bash

echo "🔍 Checking Dart code formatting..."

# 포맷팅이 필요한 파일이 있는지 확인
if dart format --set-exit-if-changed . > /dev/null 2>&1; then
    echo "✅ All files are properly formatted"
    exit 0
else
    echo "❌ Code formatting issues found!"
    echo "Please run 'dart format .' to fix formatting issues"
    exit 1
fi
