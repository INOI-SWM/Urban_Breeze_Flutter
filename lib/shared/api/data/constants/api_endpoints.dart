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
}
