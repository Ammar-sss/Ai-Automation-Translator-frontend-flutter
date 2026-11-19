import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:smart_translator_test/core/network/auth_interceptor.dart';
import 'package:smart_translator_test/core/network/network_interceptor.dart';
import 'package:smart_translator_test/core/storage/secure_storage_service.dart';

import '../config/env.dart';
import 'network_cubit.dart';

class DioClient {
  final Dio dio;

  DioClient({
    required SecureStorageService storage,
    NetworkCubit? networkCubit,
    void Function()? onUnauthenticated,
    Dio? customDio,
  }) : dio =
           customDio ??
           Dio(
             BaseOptions(
               baseUrl: Env.baseUrl,
               connectTimeout: Env.connectTimeout,
               receiveTimeout: Env.receiveTimeout,
               headers: {
                 "Content-Type": "application/json",
                 "Accept": "application/json",
               },
             ),
           ) {
    if (networkCubit != null) {
      dio.interceptors.add(NetworkInterceptor(networkCubit: networkCubit));
    }

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        storage: storage,
        onUnauthenticated: onUnauthenticated,
      ),
    );

    if (kDebugMode || Env.isDevelopment) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: false,
          responseHeader: true,
          error: true,
        ),
      );
    }
  }
}
