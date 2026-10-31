import 'package:inventario/core/error/app_failure.dart';

/// Excepción lanzada por las reglas de dominio cuando una operación no es válida.
class DomainException implements Exception {
  const DomainException(this.code, this.message);

  final String code;
  final String message;

  AppFailure toFailure() => AppFailure(code, message);

  @override
  String toString() => message;
}
