class APIException implements Exception {
  final dynamic message;
  final int statusCode;

  const APIException({required this.message, required this.statusCode});
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});
}
