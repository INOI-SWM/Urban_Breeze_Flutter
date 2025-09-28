class FeedbackRequestModel {
  const FeedbackRequestModel({required this.content});

  final String content;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'content': content};
  }
}
