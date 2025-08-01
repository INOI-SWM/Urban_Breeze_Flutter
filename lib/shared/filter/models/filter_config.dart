import 'filter_item.dart';

//화면별로 다른 필터 설정을 위한 인터페이스
abstract class FilterConfig {
  List<FilterItem> get filters;
}
