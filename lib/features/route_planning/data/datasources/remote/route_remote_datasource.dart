import 'package:http/http.dart' as http;
import 'package:ridingmate/features/route_planning/data/models/route_save_request_model.dart';
import 'package:ridingmate/features/route_planning/data/models/route_save_response_model.dart';
import 'package:ridingmate/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

class RouteRemoteDataSource extends BaseRemoteDataSource {
  RouteRemoteDataSource({super.client});

  Future<RouteSaveResponseModel> saveRoute(
    RouteSaveRequestModel request,
  ) async {
    try {
      final http.Response response = await post(
        '/api/routes',
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

      throw RouteSaveException('서버 오류 (${response.statusCode})');
    } on RouteSaveException {
      rethrow;
    }
    // BaseRemoteDataSource에서 NetworkException, ParsingException 처리
  }
}
