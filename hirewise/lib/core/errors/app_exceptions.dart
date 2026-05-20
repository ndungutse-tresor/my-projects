class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException()
      : super('No internet connection. Please check your network.');
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
