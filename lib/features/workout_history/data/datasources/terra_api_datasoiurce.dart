import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terra_flutter_bridge/models/responses.dart';
import 'package:terra_flutter_bridge/terra_flutter_bridge.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';

class TerraApiDataSource {
  TerraApiDataSource(this.ref);

  final Ref ref;
  final TerraFlutter terraFlutter = TerraFlutter();

  Future<void> initTerra() async {
    final String devId = dotenv.env['TERRA_DEV_ID']!;

    final User? user = ref.read(userSessionNotifierProvider);
    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final String referenceId = user.id;

    final SuccessMessage? result = await TerraFlutter.initTerra(
      devId,
      referenceId,
    );

    if (result?.error != null) {
      throw Exception(result?.error);
    }
  }
}
