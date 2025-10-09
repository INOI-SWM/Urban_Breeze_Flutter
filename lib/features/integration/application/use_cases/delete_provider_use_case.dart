import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/domain/repositories/provider_repository.dart';

class DeleteProviderUseCase {
  const DeleteProviderUseCase({required this.repository});

  final ProviderRepository repository;

  Future<AppResult<void>> execute(String providerName) async {
    try {
      await repository.deleteProvider(providerName);
      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(NetworkException(e.toString()));
    }
  }
}
