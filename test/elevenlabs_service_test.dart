import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_translator_test/core/network/elevenlabs_service.dart';

class MockInterceptor extends Interceptor {
  RequestOptions? lastRequestOptions;
  dynamic lastData;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    lastRequestOptions = options;
    lastData = options.data;
    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: Uint8List.fromList([1, 2, 3, 4, 5]),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationSupportDirectory') {
            final tempDir = Directory.systemTemp.createTempSync('tts_test_');
            return tempDir.path;
          }
          return null;
        });
  });

  group('ElevenLabsService Direct API Tests', () {
    test(
      'textToSpeech calls ElevenLabs API endpoint with xi-api-key',
      () async {
        final dio = Dio();
        final interceptor = MockInterceptor();
        dio.interceptors.add(interceptor);

        final service = ElevenLabsService(dio);
        final result = await service.textToSpeech(
          'Hello world',
          languageCode: 'en',
        );

        expect(result, isNotNull);
        expect(interceptor.lastRequestOptions, isNotNull);
        expect(
          interceptor.lastRequestOptions!.uri.toString(),
          contains('api.elevenlabs.io'),
        );
        expect(interceptor.lastRequestOptions!.method, equals('POST'));
        expect(
          interceptor.lastRequestOptions!.headers.containsKey('xi-api-key'),
          isTrue,
        );

        final Map<String, dynamic> data = interceptor.lastData;
        expect(data['text'], equals('Hello world'));
        expect(data['language_code'], equals('en'));
      },
    );
  });
}
