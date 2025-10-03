# 🌍 환경 설정 가이드 (Environment Setup Guide)

## 📋 개요

Urban Breeze 프로젝트는 개발(Dev), 스테이징(Staging), 프로덕션(Prod) 세 가지 환경을 지원합니다.

## 🔧 초기 설정

### 1. 환경 변수 파일 생성

프로젝트 루트에 다음 세 개의 파일을 생성하세요:

```
Urban_Breeze_Flutter/
├── .env.dev          # 개발 환경
├── .env.staging      # 스테이징 환경
└── .env.prod         # 프로덕션 환경
```

### 2. 환경 변수 설정

각 `.env` 파일에 아래 내용을 작성하세요:

#### `.env.dev` (개발 환경)

```env
API_BASE_URL=https://dev-api.urbanbreeze.com
TERRA_DEV_ID=your-dev-terra-id
KAKAO_NATIVE_APP_KEY=your-dev-kakao-key
GOOGLE_MAPS_API_KEY=your-dev-google-maps-key
AMPLITUDE_API_KEY=your-dev-amplitude-key
ENV_NAME=development
```

#### `.env.staging` (스테이징 환경)

```env
API_BASE_URL=https://staging-api.urbanbreeze.com
TERRA_DEV_ID=your-staging-terra-id
KAKAO_NATIVE_APP_KEY=your-staging-kakao-key
GOOGLE_MAPS_API_KEY=your-staging-google-maps-key
AMPLITUDE_API_KEY=your-staging-amplitude-key
ENV_NAME=staging
```

#### `.env.prod` (프로덕션 환경)

```env
API_BASE_URL=https://api.urbanbreeze.com
TERRA_DEV_ID=your-prod-terra-id
KAKAO_NATIVE_APP_KEY=your-prod-kakao-key
GOOGLE_MAPS_API_KEY=your-prod-google-maps-key
AMPLITUDE_API_KEY=your-prod-amplitude-key
ENV_NAME=production
```

## 🚀 실행 방법

### 터미널에서 실행

```bash
# 개발 환경
flutter run -t lib/main_dev.dart

# 스테이징 환경
flutter run -t lib/main_staging.dart

# 프로덕션 환경 (Debug)
flutter run -t lib/main_prod.dart

# 프로덕션 환경 (Release)
flutter run -t lib/main_prod.dart --release
```

### VS Code에서 실행

1. VS Code의 디버그 패널 (⌘+Shift+D 또는 Ctrl+Shift+D) 열기
2. 상단의 드롭다운에서 원하는 환경 선택:
   - `Dev (개발)`
   - `Staging (스테이징)`
   - `Prod (프로덕션 - Debug)`
   - `Prod (프로덕션 - Release)`
3. 실행 버튼(▶️) 클릭 또는 F5 키 누르기

### Android Studio / IntelliJ에서 실행

1. Run > Edit Configurations...
2. `+` 버튼 클릭하여 새 Flutter 구성 추가
3. 각 환경별로 다음과 같이 설정:
   - Name: `Dev` / `Staging` / `Prod`
   - Dart entrypoint: `lib/main_dev.dart` / `lib/main_staging.dart` / `lib/main_prod.dart`

## 📱 빌드

### Android

```bash
# 개발 환경
flutter build apk -t lib/main_dev.dart

# 스테이징 환경
flutter build apk -t lib/main_staging.dart

# 프로덕션 환경
flutter build apk -t lib/main_prod.dart --release
```

### iOS

```bash
# 개발 환경
flutter build ios -t lib/main_dev.dart

# 스테이징 환경
flutter build ios -t lib/main_staging.dart

# 프로덕션 환경
flutter build ios -t lib/main_prod.dart --release
```

## 🔐 보안

- `.env.dev`, `.env.staging`, `.env.prod` 파일은 `.gitignore`에 포함되어 Git에 커밋되지 않습니다.
- 실제 API 키와 시크릿은 팀 내부 문서나 비밀 관리 시스템에 안전하게 보관하세요.
- 새로운 팀원이 합류하면 `.env.example` 파일을 참고하여 환경 변수를 설정하도록 안내하세요.

## 📝 환경별 차이점

| 항목               | Development              | Staging                     | Production              |
| ------------------ | ------------------------ | --------------------------- | ----------------------- |
| API URL            | dev-api.urbanbreeze.com  | staging-api.urbanbreeze.com | api.urbanbreeze.com     |
| Amplitude Instance | urban_breeze_development | urban_breeze_staging        | urban_breeze_production |
| 디버그 로그        | 활성화                   | 활성화                      | 비활성화                |

## 🆘 문제 해결

### "AMPLITUDE_API_KEY가 설정되지 않았습니다" 에러

- `.env.dev`, `.env.staging`, `.env.prod` 파일이 프로젝트 루트에 있는지 확인
- 각 파일에 `AMPLITUDE_API_KEY` 값이 설정되어 있는지 확인

### 환경이 제대로 로드되지 않음

1. 앱을 완전히 종료
2. `flutter clean` 실행
3. `flutter pub get` 실행
4. 앱 재실행

## 📞 지원

문제가 지속되면 팀의 기술 리드에게 문의하세요.
