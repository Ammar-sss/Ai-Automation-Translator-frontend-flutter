import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class ElevenLabsService {
  final Dio _dio;
  // Replace with your ElevenLabs API Key or inject via secure storage / env
  final String _apiKey = 'sk_f157cb4917d414e84b48d538bc6439885b98c40e01877aca';
  // Default voice ID (e.g. Rachel, Adam, or custom voice ID)
  final String _defaultVoiceId = 'JBFqnCBsd6RMkjVDRZzb';

  ElevenLabsService(this._dio);

  Future<File> _cacheFile(String text, String voiceId) async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'tts_cache'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final key = md5.convert(
      utf8.encode('$voiceId|${text.trim().toLowerCase()}'),
    );
    return File(p.join(dir.path, '$key.mp3'));
  }

  Future<Uint8List?> textToSpeech(
    String text, {
    String languageCode = 'en', // e.g. 'en', 'ar'
    String? voiceId,
  }) async {
    try {
      final vId = voiceId ?? _defaultVoiceId;
      final file = await _cacheFile(text, '$vId|$languageCode');
      if (await file.exists()) return await file.readAsBytes();

      final url = 'https://api.elevenlabs.io/v1/text-to-speech/$vId';

      final response = await _dio.post(
        url,
        data: {
          'text': text,
          'model_id': 'eleven_turbo_v2_5',
          'language_code': languageCode,
          'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75},
        },
        options: Options(
          headers: {
            'xi-api-key': _apiKey,
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final bytes = Uint8List.fromList(response.data);
        await file.writeAsBytes(bytes, flush: true);
        return bytes;
      }
      return null;
    } catch (e) {
      debugPrint('ElevenLabs TTS Error: $e');
      if (e is DioException) {
        debugPrint('Dio error response: ${e.response?.data}');
      }
      return null;
    }
  }
}
