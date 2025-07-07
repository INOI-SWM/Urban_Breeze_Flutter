class ApiErrorModel {
  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      field: json['field'] as String,
      value: json['value'] as String,
      reason: json['reason'] as String,
    );
  }

  const ApiErrorModel({
    required this.field,
    required this.value,
    required this.reason,
  });

  final String field;
  final String value;
  final String reason;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'field': field, 'value': value, 'reason': reason};
  }
}
