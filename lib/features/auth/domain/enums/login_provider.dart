enum LoginProvider { google, apple, kakao }

extension LoginProviderExtension on LoginProvider {
  String get name {
    switch (this) {
      case LoginProvider.google:
        return 'Google';
      case LoginProvider.apple:
        return 'Apple';
      case LoginProvider.kakao:
        return 'Kakao';
    }
  }

  static LoginProvider fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'google':
        return LoginProvider.google;
      case 'apple':
        return LoginProvider.apple;
      case 'kakao':
        return LoginProvider.kakao;
      default:
        throw ArgumentError('Unknown login provider: $value');
    }
  }
}
