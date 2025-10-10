# 🚀 Release 관리 완전 가이드

Urban Breeze Flutter 앱의 Git Flow 기반 Release 자동화 시스템 전체 문서입니다.

---

## 📖 목차

- [빠른 시작](#-빠른-시작)
- [Git Flow 구조](#-git-flow-구조)
- [상세 프로세스](#-상세-프로세스)
- [GitHub Actions](#-github-actions)
- [스크립트 설명](#-스크립트-설명)
- [버전 관리 규칙](#-버전-관리-규칙)
- [Troubleshooting](#-troubleshooting)

---

## ⚡ 빠른 시작

### 3단계 Release

```bash
# 1. CHANGELOG 작성
vi CHANGELOG.md
git add CHANGELOG.md && git commit -m "docs: update CHANGELOG" && git push

# 2. Release 실행
./scripts/release.sh 1.0.0+6

# 3. GitHub에서 PR 머지
# → 자동으로 Tag 생성 & Release 발행됨!
```

**자세한 내용:** [RELEASE_QUICK_START.md](RELEASE_QUICK_START.md)

---

## 🌊 Git Flow 구조

### 브랜치 전략

```
main (production)
  ↑
develop (staging)
  ↑
feature/* (개발)
  ↑
release/* (릴리즈 준비)
```

### Release 플로우

```
1. 여러 feature 개발
   feat/garmin → develop
   feat/suunto → develop
   feat/webview → develop

2. develop에 기능들이 모임

3. Release 브랜치 생성
   develop → release/1.0.0+6

4. 최종 검증 & 머지
   release/1.0.0+6 → develop

5. 자동 Tag 생성
   → v1.0.0+6

6. 자동 Release 발행
   → GitHub Releases
```

---

## 📋 상세 프로세스

### Phase 1: 개발 (Feature 브랜치)

```bash
# Feature 브랜치 생성 (Jira 티켓 기반)
git checkout -b feat/INOI-100/garmin-integration

# 개발 & 커밋
git add .
git commit -m "feat: Garmin 연동 기능 추가"
git push origin feat/INOI-100/garmin-integration

# PR 생성 → 리뷰 → develop 머지
```

**반복:** 다른 feature들도 동일하게 develop에 머지

---

### Phase 2: Release 준비 (develop 브랜치)

**Step 1: develop 최신화**

```bash
git checkout develop
git pull origin develop
```

**Step 2: CHANGELOG 작성**

```bash
vi CHANGELOG.md
```

```markdown
## [Unreleased]

### ✨ Features

- Garmin Connect 연동 기능
- Suunto 연동 기능
- 웹뷰 자동 닫기

### 🐛 Bug Fixes

- Provider 매칭 오류 수정
```

**Step 3: 커밋**

```bash
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for next release"
git push origin develop
```

---

### Phase 3: Release 브랜치 생성 (스크립트)

```bash
./scripts/release.sh 1.0.0+6
```

**스크립트가 자동으로:**

1. Release 브랜치 생성

   ```
   release/1.0.0+6
   ```

2. 파일 업데이트

   - `pubspec.yaml`: version → 1.0.0+6
   - `CHANGELOG.md`: [Unreleased] → [1.0.0+6 - 2025-10-10]
   - 새 [Unreleased] 섹션 추가

3. 커밋 & Push

   ```
   chore: prepare release 1.0.0+6
   ```

4. PR 생성 (GitHub CLI 설치 시)
   ```
   Title: Release v1.0.0+6
   Base: develop ← Head: release/1.0.0+6
   ```

---

### Phase 4: 검증 & 머지 (GitHub)

**Step 1: CI 자동 실행**

- ✅ flutter analyze
- ✅ format check
- ✅ CHANGELOG 업데이트 확인
- ✅ 버전 형식 검증

**Step 2: 리뷰 (선택)**

- 팀원 리뷰 요청
- 또는 바로 머지

**Step 3: Merge**

- "Merge pull request" 클릭

---

### Phase 5: 자동 Tag 생성 (GitHub Actions)

**release-merge.yml 실행:**

1. PR 머지 감지
2. 브랜치명에서 버전 추출
   ```
   release/1.0.0+6 → 1.0.0+6
   ```
3. Tag 생성 & Push
   ```
   v1.0.0+6
   ```
4. Release 브랜치 삭제
5. PR에 완료 코멘트

**소요 시간:** 약 10초

---

### Phase 6: Release 발행 (GitHub Actions)

**release-publish.yml 실행:**

1. Tag 푸시 감지
2. CHANGELOG.md 파싱
3. 커밋 목록 생성
4. Release Notes 작성
5. GitHub Release 발행

**소요 시간:** 약 10초

**결과:**

```
https://github.com/INOI-SWM/Urban_Breeze_Flutter/releases/tag/v1.0.0+6
```

---

## 🤖 GitHub Actions

### Workflows 구성

| Workflow                | 트리거          | 역할          | 자동화 |
| ----------------------- | --------------- | ------------- | ------ |
| **feature-ci.yml**      | Feature PR      | 코드 검증     | ✅     |
| **release-ci.yml**      | Release PR      | Release 검증  | ✅     |
| **release-merge.yml**   | Release PR 머지 | Tag 자동 생성 | ✅     |
| **release-publish.yml** | Tag 푸시        | Release 발행  | ✅     |

### 권한 설정 (1회)

GitHub에서 설정 필요:

```
Settings → Actions → General
→ Workflow permissions
→ "Read and write permissions" 선택
→ Save
```

---

## 🛠️ 스크립트 설명

### 1. release.sh (메인 스크립트)

**기능:**

- Release 브랜치 생성
- 버전 업데이트
- CHANGELOG 정리
- PR 생성

**사용법:**

```bash
./scripts/release.sh 1.0.0+6
```

**전제 조건:**

- develop 브랜치에서 실행
- 커밋되지 않은 변경사항 없음
- CHANGELOG [Unreleased] 작성 완료

---

### 2. generate_release_notes.sh (미리보기)

**기능:**

- CHANGELOG에서 특정 버전 내용 추출

**사용법:**

```bash
./scripts/generate_release_notes.sh 1.0.0+5
```

**용도:**

- Release Notes 미리보기
- 수동 Release 작성 시 참고

---

### 3. finalize_release.sh (백업용)

**기능:**

- PR 머지 후 수동으로 Tag 생성
- GitHub Actions 실패 시 사용

**사용법:**

```bash
# Release PR 머지 후
git checkout develop
git pull origin develop
./scripts/finalize_release.sh 1.0.0+6
```

**일반적으로 사용 안 함!** (자동화되어 있음)

---

## 🔢 버전 관리 규칙

### 버전 형식

```
Major.Minor.Patch+Build
```

### 증가 규칙

| 변경 종류        | Major | Minor | Patch | Build | 예시              |
| ---------------- | ----- | ----- | ----- | ----- | ----------------- |
| 새 기능          |       | ✅    |       | ✅    | 1.0.0+5 → 1.1.0+6 |
| 버그 수정        |       |       | ✅    | ✅    | 1.0.0+5 → 1.0.1+6 |
| 리팩토링만       |       |       |       | ✅    | 1.0.0+5 → 1.0.0+6 |
| Breaking Changes | ✅    |       |       | ✅    | 1.0.0+5 → 2.0.0+6 |

### 실전 예시

```
현재: 1.0.0+5

→ Garmin/Suunto 추가 (새 기능)
→ 1.1.0+6

→ 버그만 수정
→ 1.0.1+6

→ UI만 개선 (기능 변화 없음)
→ 1.0.0+6
```

---

## 🌿 여러 Feature를 한 Release에 포함

### 방법

```bash
# 1. 각 Feature를 develop에 머지
feat/feature-A → develop (월요일)
feat/feature-B → develop (화요일)
feat/feature-C → develop (수요일)

# 2. CHANGELOG에 3개 모두 작성 (목요일)
## [Unreleased]
- Feature A
- Feature B
- Feature C

# 3. Release 실행 (금요일)
./scripts/release.sh 1.1.0+10

# → v1.1.0+10에 A, B, C 모두 포함!
```

**핵심:** develop은 "다음 릴리즈 예정" 기능들의 모음!

---

## 🎨 CHANGELOG 카테고리

```markdown
### 🏗️ Architecture - 구조 개선

### ✨ Features - 새 기능

### 🔧 Improvements - 기능 개선

### 🐛 Bug Fixes - 버그 수정

### ⚡ Performance - 성능 개선

### 🔒 Security - 보안 강화

### 📝 Documentation - 문서 업데이트
```

---

## ❓ FAQ

### Q: Release 브랜치는 왜 삭제되나요?

**A:** Release 브랜치는 **임시 작업 공간**입니다.

- ✅ 버전은 Tag로 영구 보존 (v1.0.0+6)
- ✅ 코드는 develop에 머지됨
- ✅ 브랜치 목록 깔끔하게 유지
- ✅ Git Flow 표준 방식

### Q: Tag가 안 만들어져요

**A:** 체크 사항

- Release PR이 develop에 머지되었나요?
- 브랜치명이 `release/`로 시작하나요?
- GitHub Actions 권한 설정되었나요?

### Q: GitHub CLI 없이도 되나요?

**A:** 네!

- PR은 수동으로 생성하면 됨
- 나머지는 동일하게 자동화됨

---

## 🔧 Troubleshooting

### Tag 삭제 (잘못 생성 시)

```bash
# 로컬 삭제
git tag -d v1.0.0+6

# 원격 삭제
git push origin --delete v1.0.0+6
```

### 버전 롤백

```bash
# 마지막 커밋 취소
git reset --hard HEAD~1

# Tag 삭제 후 재실행
./scripts/release.sh 1.0.0+7
```

### GitHub Actions 실패 시

```bash
# 수동으로 Tag 생성
./scripts/finalize_release.sh 1.0.0+6
```

---

## 📊 전체 구조

```
Urban_Breeze_Flutter/
├── CHANGELOG.md              # 변경 이력 (수동 작성)
├── RELEASE_QUICK_START.md   # 빠른 시작 가이드
├── RELEASE_GUIDE.md          # 이 문서 (전체 가이드)
├── .github/
│   ├── RELEASE_TEMPLATE.md   # Release 템플릿
│   └── workflows/
│       ├── feature-ci.yml
│       ├── release-ci.yml
│       ├── release-merge.yml
│       └── release-publish.yml
└── scripts/
    ├── release.sh            # Release 자동화
    ├── generate_release_notes.sh
    └── finalize_release.sh
```

---

## 🎯 개발자 작업 vs 자동화

| 단계 | 작업                | 담당      | 시간 |
| ---- | ------------------- | --------- | ---- |
| 1    | CHANGELOG 작성      | 👨‍💻 개발자 | 2분  |
| 2    | 스크립트 실행       | 👨‍💻 개발자 | 10초 |
| 3    | PR 머지             | 👨‍💻 개발자 | 1분  |
| 4    | Release 브랜치 생성 | 🤖 자동   | 1초  |
| 5    | 버전 업데이트       | 🤖 자동   | 1초  |
| 6    | CHANGELOG 정리      | 🤖 자동   | 1초  |
| 7    | PR 생성             | 🤖 자동   | 2초  |
| 8    | CI 검증             | 🤖 자동   | 30초 |
| 9    | Tag 생성            | 🤖 자동   | 2초  |
| 10   | Release 발행        | 🤖 자동   | 10초 |
| 11   | 브랜치 정리         | 🤖 자동   | 1초  |

**개발자 작업: 3분**  
**자동 처리: 48초**  
**자동화율: 94%**

---

## 🔑 핵심 개념

### 1. develop = 다음 릴리즈 모음

```
develop 브랜치는 "다음에 나갈 기능들"의 저장소

feat/A → develop ✅
feat/B → develop ✅
feat/C → develop ✅

→ develop에 A+B+C 모두 포함
→ Release 시 A+B+C 한 번에 배포
```

### 2. Release 브랜치 = 임시 작업 공간

```
release/1.0.0+6
- 버전 업데이트
- CHANGELOG 정리
- 최종 검증
- 긴급 버그 수정

머지 후 → 삭제됨 (Tag로 보존)
```

### 3. Tag = 버전의 영구 스냅샷

```
v1.0.0+6 = 해당 버전의 정확한 코드

언제든지:
git checkout v1.0.0+6  # 해당 버전으로 이동
git diff v1.0.0+5 v1.0.0+6  # 버전 간 비교
```

---

## 📝 CHANGELOG 작성 가이드

### Good ✅

```markdown
### ✨ Features

- Garmin 연동 시 인증 완료 후 자동으로 창이 닫힙니다
- 연동 실패 시 명확한 안내 메시지를 제공합니다

### 🐛 Bug Fixes

- Garmin/Suunto 연동 상태가 화면에 표시되지 않던 문제를 해결했습니다
```

### Bad ❌

```markdown
### Features

- 버그 수정
- 코드 개선
- WebView 로직 추가
```

**작성 원칙:**

- 🎯 사용자 관점 (기술 용어 최소화)
- 📌 큰 기능만 (내부 수정은 선택)
- ✅ 구체적으로 (무엇이 어떻게 좋아졌는지)

---

## 🔄 완전 자동화 다이어그램

```
┌──────────────────────────────────────┐
│  개발자 작업 (3분)                    │
├──────────────────────────────────────┤
│  1. CHANGELOG 작성                   │
│  2. ./scripts/release.sh 실행        │
│  3. PR 머지                          │
└──────────────────────────────────────┘
               ↓
┌──────────────────────────────────────┐
│  스크립트 자동화 (1초)                │
├──────────────────────────────────────┤
│  ✅ Release 브랜치 생성               │
│  ✅ 버전 업데이트                     │
│  ✅ CHANGELOG 정리                    │
│  ✅ PR 생성                           │
└──────────────────────────────────────┘
               ↓
┌──────────────────────────────────────┐
│  GitHub Actions CI (30초)            │
├──────────────────────────────────────┤
│  ✅ Analyze                          │
│  ✅ Format check                     │
│  ✅ CHANGELOG 검증                   │
│  ✅ 버전 검증                         │
└──────────────────────────────────────┘
               ↓
┌──────────────────────────────────────┐
│  개발자 머지 (1분)                    │
├──────────────────────────────────────┤
│  PR 리뷰 & Merge 버튼 클릭           │
└──────────────────────────────────────┘
               ↓
┌──────────────────────────────────────┐
│  GitHub Actions Tag (10초)           │
├──────────────────────────────────────┤
│  ✅ Tag v1.0.0+6 생성                │
│  ✅ Push                             │
│  ✅ Release 브랜치 삭제               │
│  ✅ PR 코멘트                         │
└──────────────────────────────────────┘
               ↓
┌──────────────────────────────────────┐
│  GitHub Actions Release (10초)       │
├──────────────────────────────────────┤
│  ✅ CHANGELOG 파싱                   │
│  ✅ Release Notes 생성               │
│  ✅ GitHub Release 발행              │
└──────────────────────────────────────┘
               ↓
           🎉 완료!
```

---

## 🎓 실전 예시

### 시나리오: 3개 기능을 v1.1.0+10으로 릴리즈

```bash
# === 1주차: 개발 ===
# 월: Feature A 완료
git checkout -b feat/INOI-200/feature-a
# ... 개발 ...
# PR → develop 머지 ✅

# 화: Feature B 완료
git checkout -b feat/INOI-201/feature-b
# ... 개발 ...
# PR → develop 머지 ✅

# 수: Feature C 완료
git checkout -b feat/INOI-202/feature-c
# ... 개발 ...
# PR → develop 머지 ✅

# === 2주차: Release ===
# 목: CHANGELOG 작성
git checkout develop
vi CHANGELOG.md
# [Unreleased]에 A, B, C 모두 작성
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for v1.1.0+10"
git push origin develop

# 금: Release 실행
./scripts/release.sh 1.1.0+10
# → release/1.1.0+10 생성 (A+B+C 포함)
# → PR 자동 생성

# GitHub에서 PR 머지
# → Tag v1.1.0+10 자동 생성
# → GitHub Release 자동 발행
# → 완료! 🎉
```

---

## 📌 체크리스트

### Release 전

- [ ] 모든 Feature가 develop에 머지됨
- [ ] flutter analyze 통과
- [ ] CHANGELOG [Unreleased] 작성 완료
- [ ] develop 브랜치에서 작업 중

### Release 중

- [ ] ./scripts/release.sh 실행
- [ ] GitHub PR 확인
- [ ] CI 통과 확인
- [ ] PR 머지

### Release 후

- [ ] Tag 생성 확인
- [ ] GitHub Release 발행 확인
- [ ] 팀 공지

---

## 🔧 고급 사용법

### Hotfix (긴급 수정)

```bash
# Production에 긴급 버그 발견!

# 1. Hotfix 브랜치 생성 (최신 Tag에서)
git checkout -b hotfix/1.0.0+7 v1.0.0+6

# 2. 버그 수정
# ... 수정 ...

# 3. 버전 업
sed -i '' 's/^version: .*/version: 1.0.0+7/' pubspec.yaml

# 4. 커밋
git add .
git commit -m "fix: critical bug fix"

# 5. develop에 머지
git checkout develop
git merge hotfix/1.0.0+7

# 6. main에도 머지 (production)
git checkout main
git merge hotfix/1.0.0+7

# 7. Tag 생성
git tag -a v1.0.0+7 -m "Hotfix v1.0.0+7"
git push origin v1.0.0+7

# 8. 브랜치 삭제
git branch -d hotfix/1.0.0+7
```

---

## 🌟 Best Practices

### 1. 작고 자주 릴리즈

```
❌ 나쁜 예:
- 2달에 1번, 50개 기능 포함

✅ 좋은 예:
- 1-2주에 1번, 3-5개 기능 포함
```

### 2. CHANGELOG는 사용자 친화적으로

```
❌ "WebViewController에 onPageStarted 핸들러 추가"
✅ "연동 완료 시 자동으로 화면이 닫힙니다"
```

### 3. Breaking Changes는 명확히

```markdown
### ⚠️ Breaking Changes

- API 엔드포인트 변경: `/api/v1/routes` → `/api/v2/routes`
- 마이그레이션: 앱 재설치 필요
```

---

## 📚 참고 문서

- **빠른 시작**: [RELEASE_QUICK_START.md](RELEASE_QUICK_START.md) ⭐ 먼저 읽기!
- **변경 이력**: [CHANGELOG.md](CHANGELOG.md)
- **Release 템플릿**: [.github/RELEASE_TEMPLATE.md](.github/RELEASE_TEMPLATE.md)

---

**작성일**: 2025-10-10  
**최종 업데이트**: 2025-10-10
