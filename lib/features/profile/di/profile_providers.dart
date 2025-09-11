import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/domain/repositories/user_session_repository.dart';

import '../application/use_cases/get_profile_use_case.dart';
import '../application/use_cases/update_birth_use_case.dart';
import '../application/use_cases/update_gender_use_case.dart';
import '../application/use_cases/update_introduce_use_case.dart';
import '../application/use_cases/update_nickname_use_case.dart';
import '../data/datasources/profile_datasource.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';

// DataSource
final Provider<ProfileDataSource> profileDataSourceProvider =
    Provider<ProfileDataSource>((Ref ref) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return ProfileDataSource(client: client);
    });

// Repository
final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>((Ref ref) {
      final ProfileDataSource dataSource = ref.watch(profileDataSourceProvider);
      final UserSessionRepository userSessionRepository = ref.watch(
        userSessionRepositoryProvider,
      );
      return ProfileRepositoryImpl(
        dataSource: dataSource,
        userSessionRepository: userSessionRepository,
      );
    });

// Use Cases
final Provider<GetProfileUseCase> getProfileUseCaseProvider =
    Provider<GetProfileUseCase>((Ref ref) {
      final ProfileRepository repository = ref.watch(profileRepositoryProvider);
      return GetProfileUseCase(repository: repository);
    });

final Provider<UpdateNicknameUseCase> updateNicknameUseCaseProvider =
    Provider<UpdateNicknameUseCase>((Ref ref) {
      final ProfileRepository repository = ref.watch(profileRepositoryProvider);
      return UpdateNicknameUseCase(repository: repository);
    });

final Provider<UpdateIntroduceUseCase> updateIntroduceUseCaseProvider =
    Provider<UpdateIntroduceUseCase>((Ref ref) {
      final ProfileRepository repository = ref.watch(profileRepositoryProvider);
      return UpdateIntroduceUseCase(repository: repository);
    });

final Provider<UpdateBirthUseCase> updateBirthUseCaseProvider =
    Provider<UpdateBirthUseCase>((Ref ref) {
      final ProfileRepository repository = ref.watch(profileRepositoryProvider);
      return UpdateBirthUseCase(repository: repository);
    });

final Provider<UpdateGenderUseCase> updateGenderUseCaseProvider =
    Provider<UpdateGenderUseCase>((Ref ref) {
      final ProfileRepository repository = ref.watch(profileRepositoryProvider);
      return UpdateGenderUseCase(repository: repository);
    });
