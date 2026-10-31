import 'package:inventario/core/error/error_codes.dart';

/// Fallo de negocio o de infraestructura listo para mostrarse al usuario.
class AppFailure {
  const AppFailure(this.code, this.message);

  const AppFailure.unexpected([String? detail])
      : code = ErrorCodes.unexpected,
        message = detail ?? 'Ocurrió un error inesperado.';

  final String code;
  final String message;

  @override
  String toString() => 'AppFailure($code): $message';
}
