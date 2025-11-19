import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/add_to_my_route_use_case.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/get_course_gpx_use_case.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/get_course_tcx_use_case.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/get_recommended_course_detail_use_case.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/get_recommended_course_list_usecase.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/share_recommended_course_use_case.dart';
import 'package:urban_breeze/features/recommended_course/data/datasources/recommended_course_remote_datasource.dart';
import 'package:urban_breeze/features/recommended_course/data/repositories/recommended_course_repository_impl.dart';
import 'package:urban_breeze/features/recommended_course/domain/repositories/recommended_course_repository.dart';
import 'package:urban_breeze/features/route_sharing/application/facades/route_sharing_facade.dart';
import 'package:urban_breeze/features/route_sharing/di/route_sharing_providers.dart';

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

final Provider<GetRecommendedCourseListUseCase>
getRecommendedCourseListUseCaseProvider =
    Provider<GetRecommendedCourseListUseCase>((
      Ref<GetRecommendedCourseListUseCase> ref,
    ) {
      final RecommendedCourseRepository repository = ref.watch(
        recommendedCourseRepositoryProvider,
      );
      return GetRecommendedCourseListUseCase(repository: repository);
    });

final Provider<GetRecommendedCourseDetailUseCase>
getRecommendedCourseDetailUseCaseProvider =
    Provider<GetRecommendedCourseDetailUseCase>((
      Ref<GetRecommendedCourseDetailUseCase> ref,
    ) {
      final RecommendedCourseRepository repository = ref.watch(
        recommendedCourseRepositoryProvider,
      );
      return GetRecommendedCourseDetailUseCase(repository: repository);
    });

final Provider<AddToMyRouteUseCase> addToMyRouteUseCaseProvider =
    Provider<AddToMyRouteUseCase>((Ref<AddToMyRouteUseCase> ref) {
      final RecommendedCourseRepository repository = ref.watch(
        recommendedCourseRepositoryProvider,
      );
      return AddToMyRouteUseCase(repository: repository);
    });

final Provider<GetCourseGpxUseCase> getCourseGpxUseCaseProvider =
    Provider<GetCourseGpxUseCase>((Ref<GetCourseGpxUseCase> ref) {
      final RecommendedCourseRepository repository = ref.watch(
        recommendedCourseRepositoryProvider,
      );
      return GetCourseGpxUseCase(repository: repository);
    });

final Provider<GetCourseTcxUseCase> getCourseTcxUseCaseProvider =
    Provider<GetCourseTcxUseCase>((Ref<GetCourseTcxUseCase> ref) {
      final RecommendedCourseRepository repository = ref.watch(
        recommendedCourseRepositoryProvider,
      );
      return GetCourseTcxUseCase(repository: repository);
    });

final Provider<ShareRecommendedCourseUseCase>
shareRecommendedCourseUseCaseProvider = Provider<ShareRecommendedCourseUseCase>(
  (Ref<ShareRecommendedCourseUseCase> ref) {
    final GetCourseGpxUseCase getCourseGpxUseCase = ref.watch(
      getCourseGpxUseCaseProvider,
    );
    final GetCourseTcxUseCase getCourseTcxUseCase = ref.watch(
      getCourseTcxUseCaseProvider,
    );
    final RouteSharingFacade routeSharingFacade = ref.watch(
      routeSharingFacadeProvider,
    );
    return ShareRecommendedCourseUseCase(
      getCourseGpxUseCase: getCourseGpxUseCase,
      getCourseTcxUseCase: getCourseTcxUseCase,
      routeSharingFacade: routeSharingFacade,
    );
  },
);
