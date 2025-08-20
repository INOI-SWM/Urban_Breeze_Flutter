import 'package:urban_breeze/features/route_sharing/data/datasources/route_share_remote_datasource.dart';
import 'package:urban_breeze/features/route_sharing/data/models/route_share_response_model.dart';
import 'package:urban_breeze/features/route_sharing/domain/entities/route_share_link.dart';
import 'package:urban_breeze/features/route_sharing/domain/repositories/route_share_repository.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class RouteShareRepositoryImpl implements RouteShareRepository {
  const RouteShareRepositoryImpl({required RouteShareRemoteDataSource remote})
    : _remote = remote;

  final RouteShareRemoteDataSource _remote;

  @override
  Future<RouteShareLink> getShareLink(String routeId) async {
    final ApiResponseModel<RouteShareResponseModel> res = await _remote
        .getShareLink(routeId);
    return RouteShareLink(url: res.data.shareUrl);
  }
}
