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

    if (result?.error != '' && result?.error != null) {
      throw Exception(result?.error);
    }

    if (result == null || result.success != true) {
      throw Exception('Terra 초기화에 실패했습니다.');
    }
  }

  Future<void> initialiseConnection(Connection connection) async {
    final String token = await getToken();

    // 사이클링 운동 기록에 필요한 권한만 요청
    final List<CustomPermission> customPermissions = <CustomPermission>[
      CustomPermission.workoutTypes, // 운동 타입 (사이클링)
      CustomPermission.location, // GPS 경로
      CustomPermission.calories, // 칼로리
      CustomPermission.heartRate, // 심박수
      CustomPermission.exerciseDistance, // 운동 거리
      CustomPermission.speed, // 속도
      CustomPermission.activeDurations, // 운동 시간
    ];
    final bool schedulerOn = false; // 백그라운드 자동 수집 비활성화 (명시적 동기화만 사용)

    // 1. 권한 요청 (Terra SDK)
    final SuccessMessage? result = await TerraFlutter.initConnection(
      connection,
      token,
      schedulerOn,
      customPermissions,
    );

    debugPrint('initConnection result: $result');

    // 에러 체크
    if (result?.error != null && result?.error != '') {
      throw Exception(result?.error);
    }

    // 2. 실제 승인된 권한 확인
    final Set<String> grantedPermissions =
        await TerraFlutter.getGivenPermissions();
    debugPrint('Granted permissions: $grantedPermissions');

    // 3. 필요한 권한이 하나라도 승인되었는지 확인
    final List<String> requiredPermissionStrings =
        customPermissions
            .map((CustomPermission p) => p.customPermissionString)
            .toList();

    final bool hasAnyPermission = requiredPermissionStrings.any(
      (String required) => grantedPermissions.contains(required),
    );

    if (!hasAnyPermission) {
      throw Exception('권한이 승인되지 않았습니다. 헬스 앱에서 필요한 권한을 허용해주세요.');
    }

    debugPrint(
      'Permission check passed. Granted count: ${grantedPermissions.length}',
    );
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
