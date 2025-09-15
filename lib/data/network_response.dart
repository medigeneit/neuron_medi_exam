class NetworkResponse {
  final int statusCode;
  final bool isSuccess;
  late final dynamic responseData;
  late final String errorMessage;

  NetworkResponse({
    required this.statusCode,
    required this.isSuccess,
    this.responseData,
    this.errorMessage = 'Something went wrong',
  });
}
    