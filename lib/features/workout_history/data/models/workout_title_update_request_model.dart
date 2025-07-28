class WorkoutTitleUpdateRequestModel {
  const WorkoutTitleUpdateRequestModel({required this.title});

  final String title;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'title': title};
  }
}
