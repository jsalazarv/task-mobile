import 'package:dio/dio.dart';
import 'package:hometasks/core/error/exceptions.dart';

/// Interceptor para manejar errores HTTP y convertirlos a excepciones personalizadas
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _handleError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badCertificate:
        return const ServerException(
          message: 'Bad certificate. Please try again later.',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Connection error. Please check your internet connection.',
        );

      case DioExceptionType.cancel:
        return const ServerException(
          message: 'Request cancelled',
          code: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.unknown:
        return const NetworkException(
          message: 'Unknown network error occurred',
        );
    }
  }

  AppException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    var message = 'Server error occurred';
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? message;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          code: '400',
          details: data,
        );

      case 401:
        return UnauthorizedException(
          message: message,
          code: '401',
          details: data,
        );

      case 403:
        return AuthenticationException(
          message: 'Access forbidden',
          code: '403',
          details: data,
        );

      case 404:
        return NotFoundException(
          message: message,
          code: '404',
          details: data,
        );

      case 409:
        return ValidationException(
          message: message,
          code: '409',
          details: data,
        );

      case 422:
        return ValidationException(
          message: message,
          code: '422',
          details: data,
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          message: 'Server error. Please try again later.',
          code: statusCode.toString(),
          details: data,
        );

      default:
        return ServerException(
          message: message,
          code: statusCode?.toString(),
          details: data,
        );
    }
  }
}
