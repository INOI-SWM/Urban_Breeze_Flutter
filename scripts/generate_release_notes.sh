#!/bin/bash

# CHANGELOG.md에서 특정 버전의 Release Notes 추출
# 사용법: ./scripts/generate_release_notes.sh <version>
# 예: ./scripts/generate_release_notes.sh 1.0.0+5

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "❌ 버전을 입력해주세요."
  echo ""
  echo "사용법: ./scripts/generate_release_notes.sh <version>"
  echo "예제: ./scripts/generate_release_notes.sh 1.0.0+5"
  exit 1
fi

if [ ! -f "CHANGELOG.md" ]; then
  echo "❌ CHANGELOG.md 파일을 찾을 수 없습니다."
  exit 1
fi

echo "📋 Release Notes for v$VERSION"
echo "================================"
echo ""

# CHANGELOG.md에서 해당 버전 섹션 추출
if grep -q "\[$VERSION\]" CHANGELOG.md; then
  # 버전 섹션 시작부터 다음 ## 까지 추출
  sed -n "/## \[$VERSION\]/,/## \[/p" CHANGELOG.md | sed '$d' | tail -n +2
  echo ""
  echo "✅ Release notes 생성 완료!"
else
  echo "⚠️  CHANGELOG.md에서 버전 [$VERSION]을 찾을 수 없습니다."
  echo ""
  echo "CHANGELOG.md를 먼저 업데이트해주세요:"
  echo "  ## [$VERSION] - $(date +%Y-%m-%d)"
  exit 1
fi

