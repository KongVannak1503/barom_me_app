sealed class Failure {
  final String message;
  final int? statusCode;
  final dynamic data;

  const Failure({required this.message, this.statusCode, this.data});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error', super.statusCode, super.data});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed', super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.statusCode, super.data});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Not found', super.statusCode});
}

Failure parseFailure(dynamic error) {
  if (error is Exception) {
    final str = error.toString();
    if (str.contains('401')) return const AuthFailure();
    if (str.contains('422')) return const ValidationFailure(message: 'Validation failed');
    if (str.contains('404')) return const NotFoundFailure();
    if (str.contains('SocketException') || str.contains('Connection refused')) {
      return const NetworkFailure();
    }
  }
  return ServerFailure(message: error.toString());
}
