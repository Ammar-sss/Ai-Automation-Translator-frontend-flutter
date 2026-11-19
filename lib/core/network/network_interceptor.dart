import 'package:dio/dio.dart';

import 'network_cubit.dart';

class NetworkInterceptor extends Interceptor {
  final NetworkCubit networkCubit;

  NetworkInterceptor({required this.networkCubit});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!networkCubit.isConnected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No internet connection. Operating in offline mode.',
        ),
      );
    }
    return handler.next(options);
  }
}
