class ProfileUpdateRequestModel {
  const ProfileUpdateRequestModel({required this.value});

  final String value;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'value': value};
  }
}
