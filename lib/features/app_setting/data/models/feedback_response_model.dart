class FeedbackResponseModel {
  const FeedbackResponseModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedbackResponseModel.fromJson(Map<String, dynamic> json) {
    return FeedbackResponseModel(
      id: json['id'] as int,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  final int id;
  final String content;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
