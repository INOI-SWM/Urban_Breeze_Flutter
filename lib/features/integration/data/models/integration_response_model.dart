import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

/// 연동 응답 모델
class IntegrationResponseModel {
  const IntegrationResponseModel({required this.url});

  factory IntegrationResponseModel.fromJson(Map<String, dynamic> json) {
    return IntegrationResponseModel(url: json['url'] as String);
  }

  final String url;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'url': url};
  }
}

/// 연동 API 응답 타입 정의
typedef IntegrationApiResponse = ApiResponseModel<IntegrationResponseModel>;
