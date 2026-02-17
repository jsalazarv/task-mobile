import 'package:dartz/dartz.dart';
import 'package:hometasks/core/error/failures.dart';

/// Value object que representa una contraseña válida.
final class PasswordValueObject {
  const PasswordValueObject._(this.value);

  static const int minLength = 8;

  /// Retorna [Right(PasswordValueObject)] si la contraseña es válida,
  /// o [Left(ValidationFailure)] si no cumple los requisitos.
  static Either<ValidationFailure, PasswordValueObject> create(String raw) {
    if (raw.isEmpty) {
      return const Left(ValidationFailure(message: 'La contraseña es requerida'));
    }

    if (raw.length < minLength) {
      return Left(
        ValidationFailure(
          message: 'La contraseña debe tener al menos $minLength caracteres',
        ),
      );
    }

    return Right(PasswordValueObject._(raw));
  }

  final String value;

  @override
  String toString() => '*' * value.length;

  @override
  bool operator ==(Object other) =>
      other is PasswordValueObject && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
