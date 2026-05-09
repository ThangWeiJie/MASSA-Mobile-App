class AuthValidationException implements Exception {
  final String message;

  const AuthValidationException(this.message);

  @override
  String toString() => message;
}

class AuthEmailValidator {
  static const String allowedDomain = 'graduate.utm.my';
  static const String allowedEmailMessage =
      'Please use your UTM graduate email address (@graduate.utm.my).';

  static bool isAllowedUtmEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    return normalizedEmail.endsWith('@$allowedDomain');
  }

  static void requireAllowedUtmEmail(String email) {
    if (!isAllowedUtmEmail(email)) {
      throw const AuthValidationException(allowedEmailMessage);
    }
  }
}
