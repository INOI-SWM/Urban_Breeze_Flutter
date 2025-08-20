import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/design_system/widgets/category/category_info.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';
import 'package:urban_breeze/shared/filter/models/filter_item.dart';
import 'package:urban_breeze/shared/filter/utils/filter_display_utils.dart';

/// 추천 코스 화면의 카테고리 설정
class RecommendedCourseCategoryConfig {
  const RecommendedCourseCategoryConfig._();

  /// CategoryInfo 리스트 생성
  static List<CategoryInfo> buildCategoryInfos(
    FilterData currentFilter,
    List<FilterItem> filters,
    String selectedSortOption,
  ) {
    final List<CategoryInfo> categoryInfos = <CategoryInfo>[];

    // 정렬 옵션 추가
    categoryInfos.add(
      CategoryInfo(
        id: 'sort',
        title: selectedSortOption,
        displayText: selectedSortOption,
        rightIcon: Icons.expand_more,
      ),
    );

    // 필터 옵션들 추가
    for (final FilterItem filter in filters) {
      final String displayText = FilterDisplayUtils.getCategoryText(
        currentFilter,
        filters,
        filter.title,
      );

      final IconData? leftIcon = _getFilterIcon(filter.title);

      categoryInfos.add(
        CategoryInfo(
          id: filter.id,
          title: filter.title,
          displayText: displayText,
          leftIcon: leftIcon,
        ),
      );
    }

    return categoryInfos;
  }

  /// 필터 제목에 따른 아이콘 반환
  static IconData? _getFilterIcon(String filterTitle) {
    switch (filterTitle) {
      case '코스 종류':
        return Icons.category;
      case '지역':
        return Icons.location_on;
      case '상승 고도':
        return Icons.trending_up;
      case '거리':
        return Icons.route;
      case '난이도':
        return Icons.upgrade;
      default:
        return null;
    }
  }
}
