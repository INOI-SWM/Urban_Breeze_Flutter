/// Amplitude 이벤트 정의
/// 앱 전체에서 사용하는 이벤트명들을 중앙에서 관리
class AmplitudeEvents {
  // ===========================================
  // 인증 관련 이벤트
  // ===========================================

  /// 사용자 로그인
  static const String userLogin = 'user_login';

  /// 사용자 로그아웃
  static const String userLogout = 'user_logout';

  /// 회원가입
  static const String userSignup = 'user_signup';

  /// 소셜 로그인
  static const String socialLogin = 'social_login';

  // ===========================================
  // 운동 관련 이벤트
  // ===========================================

  /// 운동 시작
  static const String workoutStarted = 'workout_started';

  /// 운동 완료
  static const String workoutCompleted = 'workout_completed';

  /// 운동 동기화
  static const String workoutSynced = 'workout_synced';

  /// 운동 기록 조회
  static const String workoutViewed = 'workout_viewed';

  /// 운동 기록 편집
  static const String workoutEdited = 'workout_edited';

  /// 운동 통계 조회
  static const String workoutStatsViewed = 'workout_stats_viewed';

  // ===========================================
  // 건강 데이터 동기화 관련 이벤트
  // ===========================================

  /// Apple Health Kit 권한 요청
  static const String appleHealthPermissionRequested =
      'apple_health_permission_requested';

  /// Google Health Connect 권한 요청
  static const String healthConnectPermissionRequested =
      'health_connect_permission_requested';

  /// Terra API 동기화 시작
  static const String terraSyncStarted = 'terra_sync_started';

  /// Terra API 동기화 완료
  static const String terraSyncCompleted = 'terra_sync_completed';

  /// Terra API 동기화 실패
  static const String terraSyncFailed = 'terra_sync_failed';

  // ===========================================
  // 네비게이션 관련 이벤트
  // ===========================================

  /// 화면 조회
  static const String screenViewed = 'screen_viewed';

  /// 탭 전환
  static const String tabChanged = 'tab_changed';

  /// 버튼 클릭
  static const String buttonClicked = 'button_clicked';

  // ===========================================
  // 기능 사용 관련 이벤트
  // ===========================================

  /// 지도 사용
  static const String mapUsed = 'map_used';

  /// 경로 계획
  static const String routePlanned = 'route_planned';

  /// 경로 공유
  static const String routeShared = 'route_shared';

  /// 필터 사용
  static const String filterUsed = 'filter_used';

  /// 정렬 사용
  static const String sortUsed = 'sort_used';

  // ===========================================
  // 오류 관련 이벤트
  // ===========================================

  /// 앱 오류 발생
  static const String appError = 'app_error';

  /// 네트워크 오류
  static const String networkError = 'network_error';

  /// 권한 오류
  static const String permissionError = 'permission_error';
}
