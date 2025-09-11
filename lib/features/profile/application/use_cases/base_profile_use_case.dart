import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';

/// 프로필 관련 UseCase들의 공통 베이스 클래스
abstract class BaseProfileUseCase<T> {
  const BaseProfileUseCase();

  /// UseCase 실행 메서드
  Future<AppResult<User>> execute(T input) async {
    try {
      final User user = await performUpdate(input);
      return AppSuccess<User>(user);
    } on NetworkException catch (e) {
      return AppFailure<User>(e);
    } on ValidationException catch (e) {
      return AppFailure<User>(e);
    } catch (e) {
      return AppFailure<User>(
        ServerException('${getErrorMessage()}: ${e.toString()}'),
      );
    }
  }

  /// 실제 업데이트 로직을 수행하는 메서드 (하위 클래스에서 구현)
  Future<User> performUpdate(T input);

  /// 에러 메시지를 반환하는 메서드 (하위 클래스에서 구현)
  String getErrorMessage();
}
