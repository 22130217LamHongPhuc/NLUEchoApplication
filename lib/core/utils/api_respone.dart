enum StatusCode {
  INVALID_TOKEN,
  INVALID_REFRESH_TOKEN,
  USER_NOT_FOUND,
  INTERNAL_SERVER_ERROR,
  UNAUTHORIZED,
  ACCESS_DENIED,
  EMAIL_ALREADY_IN_USE,
  INVALID_FILE,
  PASSWORD_INCORRECT,
  NOT_FOUND,
  SUCCESS,
  UNKNOWN,
}

class ApiResponse<T> {
  final bool success;
  final StatusCode code;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.code,
    required this.message,
    this.data,
  });




  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      {T Function(Object? json)? fromJsonT}
      ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      code:  StatusCode.values.firstWhere(
            (e) => e.name == json['code'],
        orElse: () => StatusCode.UNKNOWN,
      ),
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}