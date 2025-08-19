import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/route_planning/data/models/route_save_request_model.dart';
import 'package:urban_breeze/features/route_planning/data/models/route_save_response_model.dart';
import 'package:urban_breeze/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class RouteRemoteDataSource extends BaseRemoteDataSource {
  RouteRemoteDataSource({super.client});

  Future<RouteSaveResponseModel> saveRoute(
    RouteSaveRequestModel request,
  ) async {
    try {
      final http.Response response = await post(
        ApiEndpoints.routes,
        body: request.toJson(),
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonMap = decodeResponse(response);

      if (statusCode == 200 || statusCode == 201) {
        final ApiResponseModel<RouteSaveResponseModel> apiResp =
            ApiResponseModel<RouteSaveResponseModel>.fromJson(
              jsonMap,
              (Map<String, dynamic> data) =>
                  RouteSaveResponseModel.fromJson(data),
            );

        return apiResp.data;
      }

      // 서버에서 전달된 구체적인 에러 메시지 추출
      final String errorMessage =
          jsonMap['message'] as String? ??
          jsonMap['error'] as String? ??
          jsonMap['errorMessage'] as String? ??
          '경로 저장에 실패했습니다';

      throw RouteSaveException('서버 오류 (${response.statusCode}): $errorMessage');
    } on RouteSaveException {
      rethrow;
    }
    // BaseRemoteDataSource에서 NetworkException, ParsingException 처리
  }
}
