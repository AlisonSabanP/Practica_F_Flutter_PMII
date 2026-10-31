import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/inventory/domain/entities/movement.dart';
import 'package:inventario/features/inventory/domain/entities/movement_request.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/inventory/domain/repositories/movement_repository.dart';
import 'package:inventario/features/inventory/domain/services/movement_validator.dart';

/// Registra un movimiento de inventario.
///
/// Delega en el repositorio la transacción que actualiza el stock y guarda el
/// movimiento como una sola operación atómica.
class RegisterMovementUseCase {
  const RegisterMovementUseCase(this._repository);

  final MovementRepository _repository;

  Future<Movement> call(MovementRequest request) async {
    MovementValidator.validate(
      type: request.type,
      quantity: request.quantity,
      reason: request.reason,
      responsible: request.responsible,
      justification: request.justification,
    );

    final String responsible = request.responsible.trim();
    if (responsible.isEmpty) {
      throw const DomainException(
        ErrorCodes.reasonRequired,
        'Configura el responsable antes de registrar movimientos.',
      );
    }

    if (request.type == MovementType.salida && request.quantity <= 0) {
      throw const DomainException(
        ErrorCodes.quantityNotPositive,
        'La cantidad de salida debe ser mayor que cero.',
      );
    }

    return _repository.registerMovement(
      MovementRequest(
        productId: request.productId,
        type: request.type,
        quantity: request.quantity,
        reason: request.reason.trim(),
        responsible: responsible,
        justification: request.justification?.trim(),
      ),
    );
  }
}
