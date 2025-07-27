import 'package:ridingmate/features/place_search/domain/exceptions/place_search_domain_exceptions.dart';
import 'package:ridingmate/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:ridingmate/features/workout_history/domain/exceptions/apple_health_kit_exceptions.dart';
import 'package:ridingmate/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';
import 'package:ridingmate/shared/domain/exceptions/base_domain_exception.dart';

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
      case EmptyQueryException _:
        return '검색어를 입력해주세요';
      case NoResultsException _:
        return '검색 결과가 없습니다. 다른 키워드로 검색해보세요';

      // Route Planning 특화 Exception
      case InvalidBboxException _:
        return '경로 정보가 올바르지 않습니다. 다시 시도해주세요';
      case RouteSaveException _:
        return '경로 저장에 실패했습니다. 다시 시도해주세요';

      // Workout History 특화 Exception
      case WorkoutTitleUpdateException _:
        return '운동 기록 제목 수정에 실패했습니다';

      // Apple HealthKit 특화 Exception
      case HealthKitPermissionException _:
        return 'Apple Health 권한이 필요합니다. 설정에서 권한을 허용해주세요';
      case HealthKitDataException _:
        return 'Apple Health 데이터를 가져올 수 없습니다';
      case HealthKitWorkoutNotFoundException _:
        return '해당 운동 기록을 찾을 수 없습니다';

      default:
        return null; // 공통 처리로 넘김
    }
  }

  static String _getCommonMessage(BaseDomainException exception) {
    switch (exception.runtimeType) {
      case NetworkException _:
        return '인터넷 연결을 확인해주세요';
      case ServerException _:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
      case ParsingException _:
        return '데이터 처리 중 오류가 발생했습니다';
      case ValidationException _:
        return exception.message; // ValidationException은 사용자용 메시지 그대로 사용
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
}
