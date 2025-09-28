class UserAgreement {
  factory UserAgreement.fromJson(Map<String, dynamic> json) {
    return UserAgreement(
      termsOfServiceAgreed: json['termsOfServiceAgreed'] as bool? ?? false,
      privacyPolicyAgreed: json['privacyPolicyAgreed'] as bool? ?? false,
      locationServiceAgreed: json['locationServiceAgreed'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
  const UserAgreement({
    required this.termsOfServiceAgreed,
    required this.privacyPolicyAgreed,
    required this.locationServiceAgreed,
    required this.isCompleted,
  });

  final bool termsOfServiceAgreed;
  final bool privacyPolicyAgreed;
  final bool locationServiceAgreed;
  final bool isCompleted;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'termsOfServiceAgreed': termsOfServiceAgreed,
      'privacyPolicyAgreed': privacyPolicyAgreed,
      'locationServiceAgreed': locationServiceAgreed,
      'isCompleted': isCompleted,
    };
  }

  UserAgreement copyWith({
    bool? termsOfServiceAgreed,
    bool? privacyPolicyAgreed,
    bool? locationServiceAgreed,
    bool? isCompleted,
  }) {
    return UserAgreement(
      termsOfServiceAgreed: termsOfServiceAgreed ?? this.termsOfServiceAgreed,
      privacyPolicyAgreed: privacyPolicyAgreed ?? this.privacyPolicyAgreed,
      locationServiceAgreed:
          locationServiceAgreed ?? this.locationServiceAgreed,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserAgreement &&
        other.termsOfServiceAgreed == termsOfServiceAgreed &&
        other.privacyPolicyAgreed == privacyPolicyAgreed &&
        other.locationServiceAgreed == locationServiceAgreed &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return termsOfServiceAgreed.hashCode ^
        privacyPolicyAgreed.hashCode ^
        locationServiceAgreed.hashCode ^
        isCompleted.hashCode;
  }

  @override
  String toString() {
    return 'UserAgreement(termsOfServiceAgreed: $termsOfServiceAgreed, privacyPolicyAgreed: $privacyPolicyAgreed, locationServiceAgreed: $locationServiceAgreed, isCompleted: $isCompleted)';
  }
}
