import 'package:inventario/core/database/app_database.dart';
import 'package:inventario/features/inventory/domain/entities/movement.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';

/// Conversión entre filas de movimientos y entidades de dominio.
class MovementMapper {
  const MovementMapper._();

  static Movement fromRow(MovementRow row, {ProductRow? productRow}) {
    return Movement(
      id: row.id,
      productId: row.productId,
      type: MovementType.fromCode(row.type),
      quantity: row.quantity,
      previousStock: row.previousStock,
      resultingStock: row.resultingStock,
      reason: row.reason,
      responsible: row.responsible,
      dateTime: row.occurredAt,
      productCode: productRow?.code,
      productName: productRow?.name,
    );
  }
}
