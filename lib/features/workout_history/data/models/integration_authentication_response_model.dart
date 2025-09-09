import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

/// 연동 인증 응답 모델
class IntegrationAuthenticationResponseModel {
  const IntegrationAuthenticationResponseModel({required this.url});

  factory IntegrationAuthenticationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return IntegrationAuthenticationResponseModel(url: json['url'] as String);
  }

  final String url;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'url': url};
  }
}

/// 연동 인증 API 응답 타입 정의
typedef IntegrationAuthenticationApiResponse =
    ApiResponseModel<IntegrationAuthenticationResponseModel>;
