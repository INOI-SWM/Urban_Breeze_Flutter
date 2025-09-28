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
  static String routeDetail(String routeId) => '/api/routes/$routeId';
  static String routeShare(String routeId) => '/api/routes/$routeId/share';
  static String routeTitle(String workoutId) =>
      '/api/activities/$workoutId/title';
  static String routeGPXDownload(String routeId) => '/api/routes/$routeId/gpx';
  static String routeDelete(String routeId) => '/api/routes/$routeId';

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
  static const String profileImagePath = '/api/v1/user/profile/image';
  static const String userAgreements = '/api/v1/user/agreements';
  static const String userWithdrawal = '/api/v1/user';

  //workout
  static String workoutList = '/api/v1/activities';
  static String workoutDetail(String activityId) =>
      '/api/v1/activities/$activityId';
  static String workoutTitle(String activityId) =>
      '/api/v1/activities/$activityId/title';
  static String workoutImages(String activityId) =>
      '/api/v1/activities/$activityId/images';
  static String workoutImageDetail(String activityId, int imageId) =>
      '/api/v1/activities/$activityId/images/$imageId';
  static String workoutDelete(String activityId) =>
      '/api/v1/activities/$activityId';

  // Feedback
  static const String feedback = '/api/feedback';

  //statistics
  static const String workoutStatistics = '/api/v1/activities/stats';
}
