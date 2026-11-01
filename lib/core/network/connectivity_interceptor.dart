import 'package:dio/dio.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!await InternetConnection().hasInternetAccess) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );
    }
    handler.next(options);
  }
}
