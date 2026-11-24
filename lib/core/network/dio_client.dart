import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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
    _configureSslPinning();

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

    if (kDebugMode && Env.isDevelopment) {
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

  void _configureSslPinning() {
    if (!kIsWeb && dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
              final expectedFingerprint = Env.sslFingerprint
                  .trim()
                  .toLowerCase();
              if (expectedFingerprint.isNotEmpty) {
                final digest = sha256.convert(cert.der);
                final certFingerprint = digest.toString().toLowerCase();
                final expectedClean = expectedFingerprint.replaceAll(':', '');
                return certFingerprint == expectedClean;
              }
              // Default: strict rejection of invalid or untrusted certificates
              return false;
            };
        return client;
      };
    }
  }
}
