# 🚀 Release 가이드

Urban Breeze Flutter 앱의 Release 관리 가이드입니다.

---

## ⚡ 빠른 시작

### Release는 자동입니다!

```bash
# 평소처럼 개발하고 커밋만 잘 쓰면:
git commit -m "feat: Garmin 연동 추가"
git commit -m "fix: 버그 수정"
git push origin develop

# → GitHub가 자동으로 Release 준비!
# → PR 머지만 하면 Release 완료!
```

---

## 📝 커밋 메시지 작성법

### Conventional Commits 형식

```
<type>: <설명>

예시:
feat: 새로운 기능 추가
fix: 버그 수정
refactor: 코드 리팩토링
```

### Type 종류

| Type       | 사용 시기    | CHANGELOG      | 버전   | 예시                                |
| ---------- | ------------ | -------------- | ------ | ----------------------------------- |
| `feat`     | 새 기능 추가 | ✨ Features    | Minor↑ | `feat: Garmin 연동 추가`            |
| `fix`      | 버그 수정    | 🐛 Bug Fixes   | Patch↑ | `fix: 연동 오류 수정`               |
| `refactor` | 코드 개선    | 🏗️ Refactoring | -      | `refactor: Clean Architecture 적용` |
| `perf`     | 성능 개선    | ⚡ Performance | -      | `perf: 로딩 속도 개선`              |
| `docs`     | 문서 수정    | 📝 Docs        | -      | `docs: README 업데이트`             |
| `chore`    | 기타 작업    | (숨김)         | -      | `chore: 의존성 업데이트`            |

### Breaking Changes (Major 버전)

```bash
# 방법 1: ! 추가
git commit -m "feat!: API v2로 전환"

# 방법 2: Footer 사용
git commit -m "feat: API v2로 전환

BREAKING CHANGE: 기존 v1 API가 제거됩니다."
```

### 커밋 예시

```bash
# ✅ Good
git commit -m "feat: Garmin Connect 연동 기능 추가"
git commit -m "fix: 연동 상태가 표시되지 않는 문제 수정"
git commit -m "refactor: Integration feature 분리"

# ❌ Bad
git commit -m "가민 추가"
git commit -m "버그 수정"
git commit -m "코드 개선"
```

---

## 🔄 Release 프로세스

### 자동으로 진행됩니다

```
1. 개발자가 feat/fix 커밋 push
   ↓
2. Release Please가 커밋 분석
   ↓
3. 충분한 변경사항이 모이면
   Release PR 자동 생성
   ↓
4. 개발자가 PR 확인 & 머지
   ↓
5. 자동으로:
   - CHANGELOG 업데이트
   - pubspec.yaml 버전 업
   - Tag 생성
   - GitHub Release 발행
   ↓
6. 완료! 🎉
```

### Release PR 예시

**자동 생성되는 PR:**

```markdown
Title: chore(main): release 1.1.0

## [1.1.0]

### ✨ Features

- Garmin Connect 연동 추가
- Suunto 연동 추가

### 🐛 Bug Fixes

- Provider 매칭 오류 수정

### 🏗️ Refactoring

- Integration feature 분리
```

**개발자가 할 일:** Merge 버튼 클릭!

---

## 🔢 버전 계산 규칙

### 자동 계산됩니다

```
feat 커밋 있음      → Minor 증가 (1.0.0 → 1.1.0)
fix만 있음         → Patch 증가 (1.0.0 → 1.0.1)
refactor/perf만    → Build만 증가 (1.0.0+5 → 1.0.0+6)
feat! 있음         → Major 증가 (1.0.0 → 2.0.0)
```

### 예시

```bash
# 현재: 1.0.0+5

# Case 1: 새 기능만
git commit -m "feat: 새 기능"
→ 1.1.0+6

# Case 2: 버그 수정만
git commit -m "fix: 버그"
→ 1.0.1+6

# Case 3: 리팩토링만
git commit -m "refactor: 구조 개선"
→ 1.0.0+6

# Case 4: Breaking Change
git commit -m "feat!: 대규모 변경"
→ 2.0.0+6
```

---

## 🛠️ 초기 설정 (1회만)

### GitHub Actions 권한

```
저장소 Settings → Actions → General
→ Workflow permissions
→ "Read and write permissions" 선택
→ "Allow GitHub Actions to create and approve pull requests" 체크
→ Save
```

**완료!** 이후로는 자동으로 작동합니다.

---

## 💡 팁

### 1. 커밋 메시지는 명확하게

```bash
# ✅ 구체적
feat: Garmin Connect 연동 성공 시 웹뷰 자동 닫기

# ❌ 모호함
feat: 개선사항
```

### 2. 작은 단위로 커밋

```bash
# ✅ 기능별로 분리
git commit -m "feat: Garmin 연동 추가"
git commit -m "feat: Suunto 연동 추가"

# ❌ 한 번에
git commit -m "feat: 연동 기능들"
```

### 3. 커밋 전 lefthook이 검증

```bash
git commit -m "가민 추가"
# ❌ 커밋 메시지는 'type: 설명' 형식을 따라야 합니다

git commit -m "feat: 가민 추가"
# ✅ 커밋 메시지 검사 통과
```

---

## 📋 CHANGELOG

### 자동 생성됩니다

Release Please가 커밋 메시지를 분석하여 자동으로 `CHANGELOG.md`를 생성합니다.

**개발자는 신경 쓸 필요 없음!**

### 형식

```markdown
## [1.1.0]

### ✨ Features

- feat 커밋들이 여기 나옴

### 🐛 Bug Fixes

- fix 커밋들이 여기 나옴

### 🏗️ Refactoring

- refactor 커밋들이 여기 나옴
```

---

## 🎯 Release 시점

### 언제 Release PR이 생성되나요?

**조건:**

- develop에 `feat` 또는 `fix` 커밋이 푸시되면
- 자동으로 Release PR 생성됨

**빈도:**

- 커밋할 때마다 PR 업데이트됨
- 머지 준비되면 언제든 머지

---

## ❓ FAQ

### Q: CHANGELOG를 직접 수정해도 되나요?

**A:** Release Please가 관리하므로 권장하지 않습니다.

- Release PR에서 자동 생성됨
- 수동 수정 시 다음 Release에서 덮어씌워질 수 있음

### Q: 버전을 직접 지정하고 싶어요

**A:** Release Please가 자동 계산합니다.

- feat → Minor, fix → Patch
- 수동 지정 불가

### Q: Release를 건너뛰고 싶어요

**A:** Release PR을 머지하지 않으면 됩니다.

- PR은 계속 업데이트되며 대기
- 준비되면 머지

### Q: 긴급 Hotfix는 어떻게?

**A:**

```bash
# main/master에서 hotfix 브랜치
git checkout -b hotfix/critical-bug

# 수정 & 커밋
git commit -m "fix!: 긴급 버그 수정"

# develop과 main 둘 다 머지
```

---

## 🔧 문제 해결

### Release PR이 생성되지 않아요

**확인 사항:**

1. develop 브랜치에 푸시했나요?
2. `feat` 또는 `fix` 커밋이 있나요?
3. GitHub Actions 권한 설정했나요?

### 버전이 이상하게 증가해요

**원인:** 커밋 타입에 따라 자동 계산됨

- `feat` → Minor 증가
- `fix` → Patch 증가
- `refactor` → Build만 증가

---

## 📚 참고 자료

- **Conventional Commits**: https://www.conventionalcommits.org/
- **Release Please**: https://github.com/googleapis/release-please

---

**완성!** 이제 커밋만 잘 쓰면 Release가 자동으로 관리됩니다! 🎉
