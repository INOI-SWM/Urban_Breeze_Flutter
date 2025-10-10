# Changelog

Urban Breeze 앱의 주요 변경사항을 기록합니다.

---

## [Unreleased]

### Added

- 추가 예정 기능

---

## [1.0.0+5] - 2025-10-10

### 🏗️ Architecture

- **Clean Architecture 리팩토링**
  - Integration feature와 Workout History feature 완전 분리
  - 의존성 방향 수정 (순환 참조 제거)
  - 12개 파일 재구조화

### ✨ Features

- **Garmin Connect 연동 개선**

  - 연동 성공 시 웹뷰 자동 닫기
  - 연동 실패 시 사용자 친화적 안내 메시지
  - 연동 상태 실시간 표시

- **Suunto 연동 개선**
  - 연동 성공 시 웹뷰 자동 닫기
  - 연동 실패 시 사용자 친화적 안내 메시지
  - 연동 상태 실시간 표시

### 🔧 Improvements

- **Amplitude Analytics 강화**
  - 연동 성공/실패 이벤트 추적
  - 실패 사유별 분석 가능

### 🐛 Bug Fixes

- Provider 매칭 오류 수정 (displayName → apiProviderName)
- Garmin/Suunto 연동 상태가 화면에 표시되지 않는 문제 해결

---

## [1.0.0+4] - 2025-10-09

### Features

- 기존 기능들...

---

## Release Notes 작성 가이드

### 버전 규칙

- **Major.Minor.Patch+Build** (예: 1.0.0+5)
- Build number는 매 배포마다 증가

### 카테고리

- 🏗️ **Architecture**: 구조 개선
- ✨ **Features**: 새로운 기능
- 🔧 **Improvements**: 개선 사항
- 🐛 **Bug Fixes**: 버그 수정
- 🔒 **Security**: 보안 관련
- 📝 **Documentation**: 문서화
- ⚡ **Performance**: 성능 개선
