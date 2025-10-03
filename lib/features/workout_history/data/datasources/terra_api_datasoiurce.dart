import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:terra_flutter_bridge/models/enums.dart';
import 'package:terra_flutter_bridge/models/responses.dart';
import 'package:terra_flutter_bridge/terra_flutter_bridge.dart';
import 'package:urban_breeze/core/config/environment_config.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

class TerraApiDataSource extends BaseRemoteDataSource {
  TerraApiDataSource({super.client, required this.ref});

  final Ref ref;
  final TerraFlutter terraFlutter = TerraFlutter();

  static String get _devId => EnvironmentConfig.terraDevId;

  Future<void> initTerra() async {
    final User? user = ref.read(userSessionNotifierProvider);
    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final String referenceId = user.uuid;
    final String devId = _devId;

    final SuccessMessage? result = await TerraFlutter.initTerra(
      devId,
      referenceId,
    );

    if (result?.error != null) {
      throw Exception(result?.error);
    }
  }

  Future<void> initialiseConnection(Connection connection) async {
    final String token = await getToken();
    final List<CustomPermission> customPermissions = <CustomPermission>[];
    final bool schedulerOn = true;

    final SuccessMessage? result = await TerraFlutter.initConnection(
      connection,
      token,
      schedulerOn,
      customPermissions,
    );

    if (result?.error != null) {
      throw Exception(result?.error);
    }
  }

  // 서버를 통해 Terra API 인증 토큰 생성
  Future<String> getToken() async {
    final User? user = ref.read(userSessionNotifierProvider);
    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    try {
      final http.Response response = await post(ApiEndpoints.terraAuthToken);

      final Map<String, dynamic> json = decodeResponse(response);
      final Map<String, dynamic> data = json['data'] as Map<String, dynamic>;
      return data['token'] as String;
    } catch (e) {
      throw Exception('토큰 생성 중 오류 발생: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getData(
    Connection connection, {
    required DateTime startDate,
    required DateTime endDate,
    bool toWebhook = true,
  }) async {
    final DataMessage? result = await TerraFlutter.getActivity(
      connection,
      startDate,
      endDate,
      toWebhook: toWebhook,
    );

    if (result?.error != null) {
      throw Exception(result?.error);
    }
    debugPrint(result?.data.toString());

    return result?.data;
  }
}
