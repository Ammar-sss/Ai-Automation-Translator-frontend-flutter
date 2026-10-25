class ApiResponse<T> {
  const ApiResponse({required this.statusCode, this.message, this.data});

  final int statusCode;
  final String? message;
  final T? data;

  /// [dataFromJson] converts the `data` node; pass e.g. `User.fromJson`.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) dataFromJson,
  ) {
    return ApiResponse<T>(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String?,
      data: json['data'] == null ? null : dataFromJson(json['data']),
    );
  }
}
