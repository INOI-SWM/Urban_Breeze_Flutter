import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/core/exceptions/base_domain_exception.dart';
import 'package:ridingmate/features/route_planning/data/models/route_segment_api_request_model.dart';
import 'package:ridingmate/features/route_planning/data/models/route_segment_api_response_model.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

class RouteSegmentRemoteDataSource extends BaseRemoteDataSource {
  RouteSegmentRemoteDataSource({super.client});

  Future<RouteApiResponseModel> fetchRoute(
    LatLng start,
    LatLng end,
    String routeMode,
  ) async {
    try {
      final RouteSegmentApiRequestModel requestModel =
          RouteSegmentApiRequestModel(start: start, end: end);

      final http.Response response = await post(
        '/api/routes/segment',
        body: requestModel.toJson(),
      );

      final Map<String, dynamic> jsonMap = decodeResponse(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final ApiResponseModel<RouteApiResponseModel> apiResp =
            ApiResponseModel<RouteApiResponseModel>.fromJson(
              jsonMap,
              (Map<String, dynamic> data) =>
                  RouteApiResponseModel.fromJson(data),
            );
        return apiResp.data;
      }
      throw ServerException(
        '서버 오류 (${response.statusCode}) ${jsonMap['message']}',
      );
    } on ServerException {
      rethrow;
    }
    // BaseRemoteDataSource에서 NetworkException, ParsingException 처리
  }
}
