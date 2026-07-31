class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? errorCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataParser,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: dataParser != null && json['data'] != null
          ? dataParser(json['data'])
          : null,
      message: json['message'] as String?,
      error: json['error'] as String?,
      errorCode: json['error_code'] as int?,
    );
  }
}
