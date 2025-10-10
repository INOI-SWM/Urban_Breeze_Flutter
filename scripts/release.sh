#!/bin/bash

# Urban Breeze Release 자동화 스크립트 (Git Flow)
# 사용법: ./scripts/release.sh <version>
# 예: ./scripts/release.sh 1.0.0+6

set -e  # 에러 발생 시 중단

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "❌ 버전을 입력해주세요."
  echo ""
  echo "사용법: ./scripts/release.sh <version>"
  echo "예제: ./scripts/release.sh 1.0.0+6"
  exit 1
fi

# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 현재 브랜치: $CURRENT_BRANCH"

# develop 브랜치에서만 실행 가능
if [ "$CURRENT_BRANCH" != "develop" ]; then
  echo "❌ develop 브랜치에서만 실행 가능합니다."
  echo "현재 브랜치: $CURRENT_BRANCH"
  exit 1
fi

# 변경사항 확인
if [[ -n $(git status -s) ]]; then
  echo "❌ 커밋되지 않은 변경사항이 있습니다."
  echo ""
  git status -s
  exit 1
fi

# develop 최신화
echo "🔄 develop 브랜치 최신화..."
git pull origin develop

RELEASE_BRANCH="release/$VERSION"

echo ""
echo "🚀 Git Flow Release 프로세스 시작: v$VERSION"
echo ""

# 1. Release 브랜치 생성
echo "🌿 1. Release 브랜치 생성: $RELEASE_BRANCH"
git checkout -b "$RELEASE_BRANCH"

# 2. pubspec.yaml 버전 업데이트
echo "📝 2. pubspec.yaml 버전 업데이트..."
sed -i '' "s/^version: .*/version: $VERSION/" pubspec.yaml

# 3. CHANGELOG.md [Unreleased] → [버전]으로 변경
echo "📋 3. CHANGELOG.md 업데이트..."
TODAY=$(date +%Y-%m-%d)
if grep -q "\[Unreleased\]" CHANGELOG.md; then
  sed -i '' "s/\[Unreleased\]/[$VERSION] - $TODAY/" CHANGELOG.md
  
  # 새로운 [Unreleased] 섹션 추가
  sed -i '' "/# Changelog/a\\
\\
---\\
\\
## [Unreleased]\\
\\
### Added\\
- \\
" CHANGELOG.md
  
  echo "✅ CHANGELOG.md 업데이트 완료"
else
  echo "⚠️  [Unreleased] 섹션을 찾을 수 없습니다. 수동으로 확인해주세요."
fi

# 4. Git commit
echo "💾 4. Release 브랜치 커밋..."
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: prepare release $VERSION"

# 5. Push release 브랜치
echo "⬆️  5. Release 브랜치 push..."
git push origin "$RELEASE_BRANCH"

# 6. GitHub CLI로 PR 생성 (설치되어 있는 경우)
echo "📬 6. Pull Request 생성..."
if command -v gh &> /dev/null; then
  gh pr create \
    --base develop \
    --head "$RELEASE_BRANCH" \
    --title "Release v$VERSION" \
    --body "## 🚀 Release v$VERSION

### 📋 변경사항
CHANGELOG.md를 참조하세요.

### ✅ 체크리스트
- [ ] flutter analyze 통과
- [ ] CHANGELOG 확인
- [ ] 버전 확인: $VERSION

---

**머지 후 자동으로:**
- Tag 생성 (v$VERSION)
- GitHub Release 발행
" \
    --assignee "@me"
  
  echo "✅ PR 생성 완료!"
  echo "🔗 PR 확인: https://github.com/INOI-SWM/Urban_Breeze_Flutter/pulls"
else
  echo "⚠️  GitHub CLI(gh)가 설치되지 않았습니다."
  echo "📝 수동으로 PR을 생성해주세요:"
  echo "   Base: develop ← Head: $RELEASE_BRANCH"
fi

echo ""
echo "✅ Release 브랜치 준비 완료!"
echo ""
echo "📋 다음 단계:"
echo "1. PR 리뷰 및 승인"
echo "2. develop으로 머지"
echo "3. 머지 후 자동으로:"
echo "   - Tag 생성 (v$VERSION)"
echo "   - GitHub Release 발행"
echo ""
echo "🔙 develop으로 돌아가기:"
echo "   git checkout develop"
echo ""

