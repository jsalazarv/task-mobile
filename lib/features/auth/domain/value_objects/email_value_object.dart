import 'package:dartz/dartz.dart';
import 'package:hometasks/core/error/failures.dart';

/// Value object que representa un email válido.
/// Falla rápido — lanza ValidationFailure si el formato es inválido.
final class EmailValueObject {
  const EmailValueObject._(this.value);

  /// Retorna [Right(EmailValueObject)] si el email es válido,
  /// o [Left(ValidationFailure)] si no lo es.
  static Either<ValidationFailure, EmailValueObject> create(String raw) {
    final trimmed = raw.trim().toLowerCase();

    if (trimmed.isEmpty) {
      return const Left(ValidationFailure(message: 'El correo es requerido'));
    }

    if (!_emailRegex.hasMatch(trimmed)) {
      return const Left(
        ValidationFailure(message: 'Ingresa un correo electrónico válido'),
      );
    }

    return Right(EmailValueObject._(trimmed));
  }

  final String value;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      other is EmailValueObject && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
