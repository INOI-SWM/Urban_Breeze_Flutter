# 🚀 Release 가이드

Urban Breeze Flutter 앱의 Release 자동화 시스템입니다.

---

## ⚡ 빠른 시작

```bash
# Conventional Commits 형식으로 커밋만 하면 됩니다!
git commit -m "feat: Garmin 연동 추가"
git push origin develop

# → GitHub에 Release PR 자동 생성/업데이트
# → 릴리즈 준비되면 PR 머지
# → 자동으로 Tag + GitHub Release 발행!
```

---

## 📝 커밋 메시지 작성법

### Conventional Commits 형식

```
<type>: <설명>

예시:
feat: Garmin 연동 기능 추가
fix: 연동 상태 표시 오류 수정
refactor: Integration feature 분리
```

### Type 종류

| Type       | 사용 시기 | CHANGELOG        | 버전 증가  | 예시                           |
| ---------- | --------- | ---------------- | ---------- | ------------------------------ |
| `feat`     | 새 기능   | ✨ Features      | **Minor↑** | `feat: Garmin 연동 추가`       |
| `fix`      | 버그 수정 | 🐛 Bug Fixes     | **Patch↑** | `fix: 연동 오류 수정`          |
| `refactor` | 코드 개선 | 🏗️ Architecture  | -          | `refactor: Clean Architecture` |
| `perf`     | 성능 개선 | ⚡ Performance   | -          | `perf: 로딩 속도 개선`         |
| `docs`     | 문서      | 📝 Documentation | -          | `docs: README 업데이트`        |
| `chore`    | 기타      | (숨김)           | -          | `chore: 의존성 업데이트`       |
| `feat!`    | Breaking  | ⚠️ BREAKING      | **Major↑** | `feat!: API v2 전환`           |

**중요:**

- `feat` → **Minor 버전 증가** (1.0.0 → 1.1.0)
- `fix` → **Patch 버전 증가** (1.0.0 → 1.0.1)

---

## 🔄 자동화 플로우

### 커밋할 때마다

```
1. 개발자: develop에 커밋 푸시
   git commit -m "feat: 새 기능"
   git push origin develop
   ↓
2. Release Please: 커밋 분석
   - feat → Minor 버전↑
   - CHANGELOG 업데이트 준비
   ↓
3. Release PR 생성 또는 업데이트
   - 제목: "chore(main): release 1.1.0"
   - 내용: 자동 생성된 CHANGELOG
   ↓
4. GitHub Pull Requests 탭에 나타남
   (대기 중... 개발자가 머지할 때까지)
```

### PR 머지할 때

```
1. 개발자: GitHub에서 Release PR 머지
   https://github.com/저장소/pulls
   → "Merge pull request" 클릭
   ↓
2. Release Please: 자동 실행
   - CHANGELOG.md 파일 생성/업데이트
   - pubspec.yaml 버전 업데이트
   - Tag 생성 (v1.1.0)
   ↓
3. GitHub Release 자동 발행
   - Release Notes 자동 작성
   - 소스 코드 zip 자동 첨부
   ↓
4. 완료! 🎉
```

---

## 📋 Release PR이란?

### Release Please가 자동 생성하는 PR

**위치:**

```
GitHub → Pull requests 탭
→ "chore(main): release x.x.x" 제목의 PR
```

**내용:**

```markdown
## [1.1.0]

### ✨ Features

- Garmin 연동 추가
- Suunto 연동 추가

### 🐛 Bug Fixes

- Provider 매칭 오류 수정

---

This PR was generated with Release Please.
```

**파일 변경:**

- `CHANGELOG.md` (새로 생성 또는 업데이트)
- `pubspec.yaml` (버전 1.0.0 → 1.1.0)
- `.release-please-manifest.json` (버전 추적)

---

## ⏰ Release 시점

### 자동 릴리즈 주기 없음!

```
❌ 매일 자동 릴리즈
❌ 매주 자동 릴리즈
❌ 매달 자동 릴리즈

✅ 개발자가 결정!
```

**Release PR 머지 = 릴리즈 시점**

### 전략

**빠른 릴리즈 (권장):**

```
기능 1-2개 완성 → PR 머지 → v1.1.0
일주일 후 → PR 머지 → v1.2.0
```

**모아서 릴리즈:**

```
2-3주 개발 (PR은 계속 업데이트)
→ 충분히 모이면 PR 머지 → v1.5.0
```

**긴급 핫픽스:**

```
버그 발견 → fix 커밋 → 즉시 PR 머지 → v1.0.1
```

---

## 🛡️ 자동 검증

### Lefthook (로컬)

**커밋 시 자동 검증:**

```bash
git commit -m "가민 추가"
↓
❌ 커밋 메시지는 Conventional Commits 형식을 따라야 합니다.

형식: <type>: <설명>
예시: feat: Garmin 연동 추가
```

**올바른 커밋:**

```bash
git commit -m "feat: Garmin 연동 추가"
↓
📌 feat 커밋: Minor 버전이 증가합니다. (예: 1.0.0 → 1.1.0)
✅ 커밋 메시지 검사 통과
```

### GitHub Actions

**Feature PR:**

- `feature-ci.yml` - flutter analyze, format check

**Release PR:**

- `release-pr-ci.yml` - CHANGELOG, 버전 검증
- 자동 코멘트로 머지 전 체크리스트 제공

---

## 🎯 실전 가이드

### 일상 개발

```bash
# 1. Feature 브랜치 생성
git checkout -b feat/INOI-100/garmin

# 2. 개발 & Conventional Commits
git commit -m "feat: Garmin 인증 API 연동"
git commit -m "feat: Garmin 연동 UI 추가"
git commit -m "fix: 인증 실패 시 에러 처리"

# 3. PR → develop 머지
# → Release Please가 자동으로 Release PR 업데이트!
```

### Release 하기

```bash
# 1. GitHub Pull Requests 확인
https://github.com/INOI-SWM/Urban_Breeze_Flutter/pulls

# 2. Release PR 확인
제목: "chore(main): release 1.1.0"
내용: 자동 생성된 CHANGELOG

# 3. 릴리즈 준비 확인
- [ ] QA 완료
- [ ] 기능 테스트 완료
- [ ] 앱스토어 제출 준비

# 4. Merge 버튼 클릭
→ 자동으로 Tag + Release 생성!

# 5. 앱스토어 제출
v1.1.0으로 제출
```

---

## 🔢 버전 계산

### 자동 계산 규칙

```
feat 커밋 있음 → Minor 증가 (1.0.0 → 1.1.0)
fix만 있음    → Patch 증가 (1.0.0 → 1.0.1)
refactor만    → 변화 없음 (feat/fix 있어야 릴리즈)
feat! 있음    → Major 증가 (1.0.0 → 2.0.0)
```

### 실전 예시

```bash
# 현재: 1.0.0

# Case 1: 새 기능 추가
git commit -m "feat: Garmin 연동"
→ Release PR: v1.1.0

# Case 2: 버그만 수정
git commit -m "fix: 버그"
→ Release PR: v1.0.1

# Case 3: Breaking Change
git commit -m "feat!: API v2"
→ Release PR: v2.0.0
```

---

## ❓ FAQ

### Q: Release PR이 생성되지 않아요

**A:** 확인 사항

- develop에 `feat` 또는 `fix` 커밋이 있나요?
- GitHub Actions 권한 설정했나요?

### Q: 버전을 수동으로 정하고 싶어요

**A:** Release Please는 자동 계산만 지원합니다.

- 수동 버전이 필요하면 다른 방식 사용 권장

### Q: CHANGELOG를 직접 수정하고 싶어요

**A:** Release Please가 자동 생성하므로 권장하지 않습니다.

- 대신 커밋 메시지를 잘 작성하세요

### Q: Release PR을 닫아도 되나요?

**A:** 네, 닫아도 됩니다.

- 다음 커밋 시 다시 열립니다

---

## 🛠️ 초기 설정 (1회)

### GitHub Actions 권한

```
저장소 Settings → Actions → General
→ Workflow permissions
→ "Read and write permissions" 선택
→ "Allow GitHub Actions to create and approve pull requests" 체크
→ Save
```

---

## 📁 파일 구조

```
Urban_Breeze_Flutter/
├── .release-please-config.json      # Release Please 설정
├── .release-please-manifest.json    # 현재 버전 추적
├── CHANGELOG.md                      # Release Please가 자동 관리
├── RELEASE_GUIDE.md                  # 이 문서
├── .lefthook/
│   └── validate-commit-msg.sh       # Conventional Commits 검증
└── .github/workflows/
    ├── feature-ci.yml               # Feature PR 검증
    ├── release-please.yml           # Release 자동화
    └── release-pr-ci.yml            # Release PR 검증
```

---

## 🎓 예제

### 1주일 개발 시나리오

```bash
# 월요일
git commit -m "feat: Garmin 연동 추가"
git push origin develop
→ Release PR 생성: v1.1.0 예정

# 화요일
git commit -m "fix: 버그 수정"
git push origin develop
→ Release PR 업데이트 (bug fix 추가)

# 수요일-목요일
(개발 중...)

# 금요일
GitHub → Pull requests → Release PR 머지
→ v1.1.0 Tag 생성
→ GitHub Release 발행
→ 앱스토어 제출!
```

---

**완료!** 이제 커밋만 잘 쓰면 Release가 자동으로 관리됩니다! 🎉

**다음 커밋부터 `feat:` 또는 `fix:` 형식으로 작성하세요!**
