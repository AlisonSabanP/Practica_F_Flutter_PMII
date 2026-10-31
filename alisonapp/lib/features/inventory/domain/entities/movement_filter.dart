import 'package:inventario/features/inventory/domain/entities/movement_type.dart';

/// Filtro de consulta del historial de movimientos.
class MovementFilter {
  const MovementFilter({
    this.productId,
    this.type,
    this.from,
    this.to,
    this.limit,
  });

  final int? productId;
  final MovementType? type;
  final DateTime? from;
  final DateTime? to;
  final int? limit;

  MovementFilter copyWith({
    int? productId,
    MovementType? type,
    DateTime? from,
    DateTime? to,
    int? limit,
    bool clearProduct = false,
    bool clearType = false,
    bool clearDates = false,
  }) {
    return MovementFilter(
      productId: clearProduct ? null : (productId ?? this.productId),
      type: clearType ? null : (type ?? this.type),
      from: clearDates ? null : (from ?? this.from),
      to: clearDates ? null : (to ?? this.to),
      limit: limit ?? this.limit,
    );
  }
}
