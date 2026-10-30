/// Domain-level failure representations, decoupled from HTTP/database libraries.
abstract class Failure {
  const Failure(this.message, [this.code]);

  final String message;
  final int? code;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection', super.code]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache error', super.code]);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}
