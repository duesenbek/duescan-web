class SolanaRpcException implements Exception {
  final List<RpcError> errors;
  final String message;

  SolanaRpcException(this.errors, this.message);

  @override
  String toString() => 'SolanaRpcException: $message';
}

class RpcError {
  final RpcErrorType type;
  final String endpoint;
  final int? statusCode;
  final String message;

  RpcError({
    required this.type,
    required this.endpoint,
    this.statusCode,
    required this.message,
  });
}

enum RpcErrorType {
  accessDenied,
  rateLimited,
  serverError,
  networkError,
}
