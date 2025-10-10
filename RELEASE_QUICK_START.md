# ⚡ Release 빠른 시작 (3분 완성!)

## 👨‍💻 개발자가 할 일 (딱 3단계)

```bash
# 1️⃣ CHANGELOG 작성 (2분)
vi CHANGELOG.md
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG"
git push origin develop

# 2️⃣ Release 실행 (10초)
./scripts/release.sh 1.0.0+6

# 3️⃣ PR 머지 (1분)
# GitHub에서 Merge 버튼 클릭

# 끝! 🎉
```

---

## 📝 CHANGELOG 작성 예시

```markdown
## [Unreleased]

### ✨ Features

- Garmin Connect 연동 기능 추가
- Suunto 연동 기능 추가

### 🐛 Bug Fixes

- 연동 상태 표시 오류 수정

### 🏗️ Architecture

- Clean Architecture 리팩토링
```

**작성 팁:**

- ✅ 큰 기능만 (사용자가 체감할 수 있는 것)
- ✅ 사용자 관점 ("뭐가 좋아졌나?")
- ❌ 내부 코드 수정은 생략

---

## 🤖 자동으로 처리되는 것

```
✅ release/1.0.0+6 브랜치 생성
✅ pubspec.yaml 버전 업데이트
✅ CHANGELOG 날짜 추가
✅ PR 생성
✅ CI 검증
✅ PR 머지 후 Tag 자동 생성
✅ GitHub Release 자동 발행
✅ Release 브랜치 삭제

= 개발자는 신경 안 써도 됨!
```

---

## 🌿 여러 Feature를 한 Release에 포함하기

```
feat/garmin → develop 머지
feat/suunto → develop 머지
feat/webview → develop 머지
     ↓
develop에 3개 기능 모두 포함됨
     ↓
./scripts/release.sh 1.0.0+6
     ↓
v1.0.0+6에 3개 기능 모두 포함!
```

**핵심:** Feature들을 **먼저 develop에 모으고** → 한 번에 Release!

---

## 📊 소요 시간

| 작업           | 시간    |
| -------------- | ------- |
| CHANGELOG 작성 | 2분     |
| 스크립트 실행  | 10초    |
| PR 머지        | 1분     |
| **합계**       | **3분** |

**자동 처리:** 나머지 전부 (약 1분)

---

## 🎨 CHANGELOG 카테고리

| 아이콘 | 카테고리     | 예시                        |
| ------ | ------------ | --------------------------- |
| 🏗️     | Architecture | Clean Architecture 리팩토링 |
| ✨     | Features     | 새 기능 추가                |
| 🔧     | Improvements | 기능 개선                   |
| 🐛     | Bug Fixes    | 버그 수정                   |
| ⚡     | Performance  | 성능 개선                   |

---

## 🔧 GitHub CLI 설치 (선택)

PR 자동 생성을 원하면:

```bash
# macOS
brew install gh
gh auth login
```

없어도 됨! 수동으로 PR 생성하라고 안내만 나옴.

---

## 📚 상세 가이드

더 자세한 내용은: **[RELEASE_GUIDE.md](RELEASE_GUIDE.md)**

---

**바로 사용 가능합니다!** 🚀
