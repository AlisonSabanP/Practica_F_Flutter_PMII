import 'package:inventario/features/inventory/domain/entities/movement.dart';
import 'package:inventario/features/inventory/domain/entities/movement_request.dart';

/// Contrato de registro y consulta del historial de movimientos.
abstract class MovementRepository {
  /// Registra el movimiento y actualiza el stock en una sola transacción.
  Future<Movement> registerMovement(MovementRequest request);

  Future<List<Movement>> getMovements({
    int? productId,
    String? type,
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  Stream<List<Movement>> watchMovements({
    int? productId,
    String? type,
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  Future<int> countMovements();
}
