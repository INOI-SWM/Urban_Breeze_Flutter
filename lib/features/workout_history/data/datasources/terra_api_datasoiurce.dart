import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:terra_flutter_bridge/models/enums.dart';
import 'package:terra_flutter_bridge/models/responses.dart';
import 'package:terra_flutter_bridge/terra_flutter_bridge.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';

class TerraApiDataSource {
  TerraApiDataSource(this.ref);

  final Ref ref;
  final TerraFlutter terraFlutter = TerraFlutter();

  static String get _devId => dotenv.env['TERRA_DEV_ID'] ?? '';
  static String get _apiKey => dotenv.env['TERRA_API_KEY'] ?? '';

  Future<void> initTerra() async {
    final String devId = dotenv.env['TERRA_DEV_ID']!;

    final User? user = ref.read(userSessionNotifierProvider);
    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final String referenceId = user.uuid;

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

  // Terra API에서 인증 토큰 생성 TODO: 백엔드 서버에서 생성하게 변경해야함
  Future<String> getToken() async {
    final User? user = ref.read(userSessionNotifierProvider);
    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    try {
      final http.Response response = await http.post(
        Uri.parse('https://api.tryterra.co/v2/auth/generateAuthToken'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'dev-id': _devId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['token'] as String;
      } else {
        throw Exception('토큰 생성 실패: ${response.statusCode} - ${response.body}');
      }
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
