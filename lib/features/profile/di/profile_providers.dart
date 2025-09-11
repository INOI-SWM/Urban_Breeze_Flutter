import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';

import '../application/providers/profile_notifier.dart';
import '../application/use_cases/get_profile_use_case.dart';
import '../application/use_cases/update_birth_use_case.dart';
import '../application/use_cases/update_gender_use_case.dart';
import '../application/use_cases/update_introduce_use_case.dart';
import '../application/use_cases/update_nickname_use_case.dart';
import '../data/datasources/profile_datasource.dart';
import '../data/datasources/profile_local_datasource.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';

// DataSource
final Provider<ProfileDataSource> profileDataSourceProvider =
    Provider<ProfileDataSource>((Ref ref) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return ProfileDataSource(client: client);
    });

final Provider<ProfileLocalDataSource> profileLocalDataSourceProvider =
    Provider<ProfileLocalDataSource>((Ref ref) {
      return const ProfileLocalDataSource();
    });

// Repository
final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>((Ref ref) {
      final ProfileDataSource dataSource = ref.watch(profileDataSourceProvider);
      final ProfileLocalDataSource localDataSource = ref.watch(
        profileLocalDataSourceProvider,
      );
      return ProfileRepositoryImpl(
        dataSource: dataSource,
        localDataSource: localDataSource,
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

// Profile Notifier
final StateNotifierProvider<ProfileNotifier, AsyncValue<User?>>
profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<User?>>((Ref ref) {
      final GetProfileUseCase getProfileUseCase = ref.watch(
        getProfileUseCaseProvider,
      );
      final UpdateNicknameUseCase updateNicknameUseCase = ref.watch(
        updateNicknameUseCaseProvider,
      );
      final UpdateIntroduceUseCase updateIntroduceUseCase = ref.watch(
        updateIntroduceUseCaseProvider,
      );
      final UpdateBirthUseCase updateBirthUseCase = ref.watch(
        updateBirthUseCaseProvider,
      );
      final UpdateGenderUseCase updateGenderUseCase = ref.watch(
        updateGenderUseCaseProvider,
      );

      return ProfileNotifier(
        getProfileUseCase: getProfileUseCase,
        updateNicknameUseCase: updateNicknameUseCase,
        updateIntroduceUseCase: updateIntroduceUseCase,
        updateBirthUseCase: updateBirthUseCase,
        updateGenderUseCase: updateGenderUseCase,
      );
    });
