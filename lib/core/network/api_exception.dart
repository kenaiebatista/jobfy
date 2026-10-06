/// Thrown by [ApiClient] for any failure talking to the backend.
sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
}

/// The backend responded with a non-2xx status code.
class ApiStatusException extends ApiException {
  final int statusCode;
  const ApiStatusException(this.statusCode, super.message);

  @override
  String toString() => 'ApiStatusException($statusCode): $message';
}

/// The request could not reach the backend at all (offline, DNS, refused,
/// timed out). This is the case a not-yet-deployed backend hits.
class ApiUnreachableException extends ApiException {
  const ApiUnreachableException([super.message = 'Could not reach the server.']);

  @override
  String toString() => 'ApiUnreachableException: $message';
}

/// The response body wasn't the JSON shape the caller expected.
class ApiDecodeException extends ApiException {
  const ApiDecodeException([super.message = 'Unexpected response from the server.']);

  @override
  String toString() => 'ApiDecodeException: $message';
}
