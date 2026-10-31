import 'package:inventario/features/inventory/domain/entities/movement.dart';
import 'package:inventario/features/inventory/domain/entities/movement_filter.dart';
import 'package:inventario/features/inventory/domain/repositories/movement_repository.dart';

/// Consulta el historial de movimientos aplicando filtros.
class GetMovementHistoryUseCase {
  const GetMovementHistoryUseCase(this._repository);

  final MovementRepository _repository;

  Future<List<Movement>> call(MovementFilter filter) {
    return _repository.getMovements(
      productId: filter.productId,
      type: filter.type?.code,
      from: filter.from,
      to: filter.to,
      limit: filter.limit,
    );
  }

  Stream<List<Movement>> watch(MovementFilter filter) {
    return _repository.watchMovements(
      productId: filter.productId,
      type: filter.type?.code,
      from: filter.from,
      to: filter.to,
      limit: filter.limit,
    );
  }
}
