import 'package:dio/dio.dart';

/// Interceptor para agregar token de autenticación a las peticiones
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // TODO(dev): Obtener token del storage cuando se implemente
    // final token = await _storage.getToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO(dev): Implementar refresh token cuando el token expire
    // if (err.response?.statusCode == 401) {
    //   // Intentar refresh token
    //   // Si falla, redirigir a login
    // }

    handler.next(err);
  }
}
