import 'package:inventario/features/inventory/domain/entities/movement_type.dart';

/// Solicitud de registro de movimiento validada por el dominio.
///
/// Para [MovementType.entrada] y [MovementType.salida], [quantity] es la
/// cantidad que entra o sale. Para [MovementType.ajuste], [quantity] es la
/// cantidad contada que pasa a ser el nuevo stock.
class MovementRequest {
  const MovementRequest({
    required this.productId,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.responsible,
    this.justification,
  });

  final int productId;
  final MovementType type;
  final int quantity;
  final String reason;
  final String responsible;
  final String? justification;
}
