import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';

class User {
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.loginProvider,
    this.isFirstLogin = false,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final LoginProvider loginProvider;
  final bool isFirstLogin;

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    LoginProvider? loginProvider,
    bool? isFirstLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      loginProvider: loginProvider ?? this.loginProvider,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
    );
  }
}
