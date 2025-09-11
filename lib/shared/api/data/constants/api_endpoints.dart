class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String googleLogin = '/api/auth/google/login';
  static const String kakaoLogin = '/api/auth/kakao/login';
  static const String appleLogin = '/api/auth/apple/login';
  static const String refreshToken = '/api/auth/refresh';

  // Routes
  static const String routes = '/api/routes';
  static const String routesSearch = '/api/routes/search';
  static const String routesSegment = '/api/routes/segment';
  static String routeShare(String routeId) => '/api/routes/$routeId/share';
  static String routeTitle(String workoutId) =>
      '/api/activities/$workoutId/title';

  //recommendation
  static const String recommendations = '/api/recommendations';

  //sync
  static const String integrationAuthentication =
      '/api/integration/authentication';
  static const String integrationAuthenticationWidget =
      '/api/integration/authentication/widget';
  static const String integrationActivity = '/api/integration/activity';

  // Profile
  static const String profile = '/api/v1/user/profile';
  static const String profileNickname = '/api/v1/user/profile/nickname';
  static const String profileIntroduce = '/api/v1/user/profile/introduce';
  static const String profileBirth = '/api/v1/user/profile/birth';
  static const String userGender = '/api/v1/user/me/gender';
}
