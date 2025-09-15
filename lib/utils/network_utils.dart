import 'dart:convert';

import 'package:dio/dio.dart';

class NetworkUtils {
  static Dio createDio({String? baseUrl}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'https://api.dexscreener.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onResponse: (res, handler) {
        // Ensure JSON Map for String body
        if (res.data is String) {
          try {
            res.data = json.decode(res.data as String);
          } catch (_) {}
        }
        handler.next(res);
      },
    ));
    return dio;
  }
}
