import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_items_row.dart';

class RouteStatsRow extends StatelessWidget {
  const RouteStatsRow({
    super.key,
    required this.totalDistance,
    required this.totalDuration,
    required this.elevationGain,
  });

  final String totalDistance;
  final String totalDuration;
  final String elevationGain;

  @override
  Widget build(BuildContext context) {
    return InfoItemsRow(
      items: <InfoItemData>[
        InfoItemData(label: '예상 소요시간', value: totalDuration),
        InfoItemData(label: '총 거리', value: totalDistance),
        InfoItemData(label: '총 상승고도', value: elevationGain),
      ],
    );
  }
}
