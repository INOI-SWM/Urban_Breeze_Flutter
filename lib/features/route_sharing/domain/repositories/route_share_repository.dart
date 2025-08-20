import 'package:urban_breeze/features/route_sharing/domain/entities/route_share_link.dart';

abstract class RouteShareRepository {
  Future<RouteShareLink> getShareLink(String routeId);
}
