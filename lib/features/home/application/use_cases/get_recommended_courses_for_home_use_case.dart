import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/home/domain/entities/recommended_courses_for_home.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/get_recommended_course_list_usecase.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_list.dart';
import 'package:urban_breeze/features/recommended_course/domain/enums/recommended_course_sort_type.dart';

class GetRecommendedCoursesForHomeUseCase {
  const GetRecommendedCoursesForHomeUseCase({
    required this.getRecommendedCourseListUseCase,
  });

  final GetRecommendedCourseListUseCase getRecommendedCourseListUseCase;

  Future<RecommendedCoursesForHome> execute() async {
    // 홈 화면용 추천 코스 3개 조회
    final RecommendedCourseFilter filter = const RecommendedCourseFilter(
      page: 0,
      size: 3,
      sortType: RecommendedCourseSortType.nearest, // 가까운 순
    );

    final AppResult<RecommendedCourseList> result =
        await getRecommendedCourseListUseCase.execute(filter: filter);

    if (result.isFailure) {
      return const RecommendedCoursesForHome(
        courses: <RecommendedCourseForHome>[],
      );
    }

    final RecommendedCourseList? courseList = result.dataOrNull;
    if (courseList == null) {
      return const RecommendedCoursesForHome(
        courses: <RecommendedCourseForHome>[],
      );
    }

    final List<RecommendedCourseForHome> courses =
        courseList.courses
            .map(
              (RecommendedCourse course) => RecommendedCourseForHome(
                id: course.routeId,
                title: course.title,
                distance: course.distanceKm,
                duration: course.durationMinutes,
                difficulty: course.difficulty,
                thumbnailImageUrl: course.thumbnailImagePath,
              ),
            )
            .toList();

    return RecommendedCoursesForHome(courses: courses);
  }
}
