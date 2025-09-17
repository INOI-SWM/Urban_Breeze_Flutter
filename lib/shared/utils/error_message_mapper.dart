import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/features/place_search/domain/exceptions/place_search_domain_exceptions.dart';
import 'package:urban_breeze/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/apple_health_kit_exceptions.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';

class ErrorMessageMapper {
  static String getErrorMessage(BaseDomainException exception) {
    final String? featureMessage = _getFeatureSpecificMessage(exception);
    if (featureMessage != null) return featureMessage;

    return _getCommonMessage(exception);
  }

  /// Feature별 특화 Exception 메시지 처리
  static String? _getFeatureSpecificMessage(BaseDomainException exception) {
    switch (exception.runtimeType) {
      // Place Search 특화 Exception
      case EmptyQueryException():
        return '검색어를 입력해주세요';
      case NoResultsException():
        return '검색 결과가 없습니다. 다른 키워드로 검색해보세요';

      // Route Planning 특화 Exception
      case InvalidBboxException():
        return '경로 정보가 올바르지 않습니다. 다시 시도해주세요';
      case RouteSaveException():
        return '경로 저장에 실패했습니다. 다시 시도해주세요';

      // Workout History 특화 Exception
      case WorkoutTitleUpdateException():
        return '운동 기록 제목 수정에 실패했습니다';

      // Apple HealthKit 특화 Exception
      case HealthKitPermissionException():
        return 'Apple Health 권한이 필요합니다. 설정에서 권한을 허용해주세요';
      case HealthKitDataException():
        return 'Apple Health 데이터를 가져올 수 없습니다';
      case HealthKitWorkoutNotFoundException():
        return '해당 운동 기록을 찾을 수 없습니다';

      default:
        return null; // 공통 처리로 넘김
    }
  }

  static String _getCommonMessage(BaseDomainException exception) {
    switch (exception.runtimeType) {
      case NetworkException():
        return '인터넷 연결을 확인해주세요';
      case ServerException():
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
      case ParsingException():
        return '데이터 처리 중 오류가 발생했습니다';
      case ValidationException():
        return _getValidationErrorMessage(exception as ValidationException);
      default:
        return exception.message.isNotEmpty
            ? exception.message
            : '알 수 없는 오류가 발생했습니다';
    }
  }

  static String getDetailedErrorMessage(BaseDomainException exception) {
    final String baseMessage = getErrorMessage(exception);

    if (exception.code != null) {
      return '$baseMessage (코드: ${exception.code})';
    }

    return baseMessage;
  }

  static String _getValidationErrorMessage(ValidationException exception) {
    switch (exception.code) {
      // Workout History 관련
      case 'WORKOUT_ID_EMPTY':
        return '운동 기록을 찾을 수 없습니다';
      case 'TITLE_EMPTY':
        return '제목은 비어있을 수 없습니다';
      case 'TITLE_TOO_LONG':
        final int maxLength = exception.data['maxLength'] as int? ?? 60;
        return '제목은 $maxLength자 이하로 입력해주세요';

      // Place Search 관련
      case 'SEARCH_QUERY_EMPTY':
        return '검색어를 입력해주세요';

      // Route Planning 관련
      case 'INSUFFICIENT_COORDINATES':
        return '경로에 충분한 좌표가 없습니다';
      case 'NEGATIVE_DISTANCE':
        return '거리는 음수일 수 없습니다';
      case 'NEGATIVE_DURATION':
        return '소요시간은 음수일 수 없습니다';

      // Profile 관련
      case 'INTRODUCE_TOO_LONG':
        final int maxLength = exception.data['maxLength'] as int? ?? 100;
        return '자기소개는 $maxLength자 이하로 입력해주세요';

      // Auth 관련
      case 'USER_NOT_LOGGED_IN':
        return '로그인이 필요합니다';

      // 기본 메시지가 있으면 사용, 없으면 기본 메시지
      default:
        return exception.message.isNotEmpty
            ? exception.message
            : '입력값이 올바르지 않습니다';
    }
  }
}
