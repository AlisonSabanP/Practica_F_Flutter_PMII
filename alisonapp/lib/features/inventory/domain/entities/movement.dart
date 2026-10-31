import 'package:inventario/features/inventory/domain/entities/movement_type.dart';

/// Movimiento de inventario confirmado. Es inmutable: un movimiento nunca se
/// edita ni se elimina, los errores se corrigen con un movimiento nuevo.
class Movement {
  const Movement({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.resultingStock,
    required this.reason,
    required this.responsible,
    required this.dateTime,
    this.productCode,
    this.productName,
  });

  final int id;
  final int productId;
  final MovementType type;
  final int quantity;
  final int previousStock;
  final int resultingStock;
  final String reason;
  final String responsible;
  final DateTime dateTime;

  /// Datos de producto resueltos para consultas de historial.
  final String? productCode;
  final String? productName;

  /// Diferencia neta aplicada al stock. Puede ser negativa en salidas.
  int get delta => resultingStock - previousStock;
}
