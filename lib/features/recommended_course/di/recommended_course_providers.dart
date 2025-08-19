import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ridingmate/core/di/core_providers.dart';
import 'package:ridingmate/features/recommended_course/application/services/recommended_course_service.dart';
import 'package:ridingmate/features/recommended_course/data/datasources/recommended_course_remote_datasource.dart';
import 'package:ridingmate/features/recommended_course/data/repositories/recommended_course_repository_impl.dart';
import 'package:ridingmate/features/recommended_course/domain/repositories/recommended_course_repository.dart';

final Provider<RecommendedCourseRemoteDataSource>
recommendedCourseRemoteDataSourceProvider =
    Provider<RecommendedCourseRemoteDataSource>((
      Ref<RecommendedCourseRemoteDataSource> ref,
    ) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return RecommendedCourseRemoteDataSource(client: client);
    });

final Provider<RecommendedCourseRepository>
recommendedCourseRepositoryProvider = Provider<RecommendedCourseRepository>((
  Ref<RecommendedCourseRepository> ref,
) {
  final RecommendedCourseRemoteDataSource remoteDataSource = ref.watch(
    recommendedCourseRemoteDataSourceProvider,
  );
  return RecommendedCourseRepositoryImpl(remoteDataSource: remoteDataSource);
});

final Provider<RecommendedCourseService> recommendedCourseServiceProvider =
    Provider<RecommendedCourseService>((Ref<RecommendedCourseService> ref) {
      final RecommendedCourseRepository repository = ref.watch(
        recommendedCourseRepositoryProvider,
      );
      return RecommendedCourseService(repository: repository);
    });
