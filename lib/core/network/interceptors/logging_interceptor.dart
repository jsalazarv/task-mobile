import 'package:dio/dio.dart';

/// Interceptor para logging de peticiones y respuestas HTTP
/// Solo debe usarse en development/staging
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logRequest(options);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(err);
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    final buffer = StringBuffer()
      ..writeln('╔════════════════════════════════════════════════════════════')
      ..writeln('║ 📤 REQUEST')
      ..writeln('╠════════════════════════════════════════════════════════════')
      ..writeln('║ Method: ${options.method}')
      ..writeln('║ URL: ${options.uri}')
      ..writeln('║ Headers: ${options.headers}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('║ Query Parameters: ${options.queryParameters}');
    }

    if (options.data != null) {
      buffer.writeln('║ Body: ${options.data}');
    }

    buffer.writeln('╚════════════════════════════════════════════════════════════');

    // ignore: avoid_print
    print(buffer.toString());
  }

  void _logResponse(Response<dynamic> response) {
    final buffer = StringBuffer()
      ..writeln('╔════════════════════════════════════════════════════════════')
      ..writeln('║ 📥 RESPONSE')
      ..writeln('╠════════════════════════════════════════════════════════════')
      ..writeln('║ Status Code: ${response.statusCode}')
      ..writeln('║ URL: ${response.requestOptions.uri}')
      ..writeln('║ Headers: ${response.headers}');

    if (response.data != null) {
      buffer.writeln('║ Body: ${response.data}');
    }

    buffer.writeln('╚════════════════════════════════════════════════════════════');

    // ignore: avoid_print
    print(buffer.toString());
  }

  void _logError(DioException err) {
    final buffer = StringBuffer()
      ..writeln('╔════════════════════════════════════════════════════════════')
      ..writeln('║ ❌ ERROR')
      ..writeln('╠════════════════════════════════════════════════════════════')
      ..writeln('║ Type: ${err.type}')
      ..writeln('║ URL: ${err.requestOptions.uri}')
      ..writeln('║ Message: ${err.message}');

    if (err.response != null) {
      buffer
        ..writeln('║ Status Code: ${err.response?.statusCode}')
        ..writeln('║ Response: ${err.response?.data}');
    }

    buffer.writeln('╚════════════════════════════════════════════════════════════');

    // ignore: avoid_print
    print(buffer.toString());
  }
}
