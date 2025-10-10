#!/bin/bash

# Release 브랜치 머지 후 Tag 생성 및 정리
# 사용법: ./scripts/finalize_release.sh <version>
# 예: ./scripts/finalize_release.sh 1.0.0+6
# 주의: Release PR이 develop에 머지된 후 실행해야 함

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "❌ 버전을 입력해주세요."
  echo ""
  echo "사용법: ./scripts/finalize_release.sh <version>"
  echo "예제: ./scripts/finalize_release.sh 1.0.0+6"
  exit 1
fi

RELEASE_BRANCH="release/$VERSION"

# develop 브랜치로 이동
echo "🔄 develop 브랜치로 이동..."
git checkout develop
git pull origin develop

# Release 브랜치가 머지되었는지 확인
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
if [ "$CURRENT_VERSION" != "$VERSION" ]; then
  echo "❌ pubspec.yaml의 버전이 $VERSION이 아닙니다."
  echo "현재 버전: $CURRENT_VERSION"
  echo ""
  echo "Release 브랜치가 develop에 머지되었는지 확인해주세요."
  exit 1
fi

echo ""
echo "🏷️  Release 마무리: v$VERSION"
echo ""

# Tag 생성
echo "1. Git tag 생성..."
git tag -a "v$VERSION" -m "Release v$VERSION

버전: $VERSION
자세한 내용은 CHANGELOG.md를 참조하세요."

# Tag push
echo "2. Tag push..."
git push origin "v$VERSION"

# Release 브랜치 삭제 (선택)
echo "3. Release 브랜치 정리..."
read -p "Release 브랜치($RELEASE_BRANCH)를 삭제하시겠습니까? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # 로컬 브랜치 삭제
  if git show-ref --verify --quiet refs/heads/"$RELEASE_BRANCH"; then
    git branch -d "$RELEASE_BRANCH"
    echo "✅ 로컬 브랜치 삭제됨"
  fi
  
  # 원격 브랜치 삭제
  if git ls-remote --heads origin "$RELEASE_BRANCH" | grep -q "$RELEASE_BRANCH"; then
    git push origin --delete "$RELEASE_BRANCH"
    echo "✅ 원격 브랜치 삭제됨"
  fi
fi

echo ""
echo "✅ Release 마무리 완료!"
echo ""
echo "🎉 GitHub Actions가 자동으로 Release를 발행합니다:"
echo "   https://github.com/INOI-SWM/Urban_Breeze_Flutter/releases"
echo ""
echo "📊 Actions 진행상황:"
echo "   https://github.com/INOI-SWM/Urban_Breeze_Flutter/actions"
echo ""

