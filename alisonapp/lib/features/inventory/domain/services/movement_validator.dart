import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';

/// Motivos sugeridos según el tipo de movimiento.
class MovementReasons {
  const MovementReasons._();

  static const List<String> entrada = <String>[
    'Compra',
    'Devolución',
    'Existencias iniciales',
    'Transferencia',
    'Otro',
  ];

  static const List<String> salida = <String>[
    'Venta',
    'Daño',
    'Pérdida',
    'Vencimiento',
    'Consumo interno',
    'Otro',
  ];

  static const List<String> ajuste = <String>[
    'Conteo físico',
    'Corrección de error',
    'Merma',
    'Otro',
  ];

  static List<String> forType(MovementType type) => switch (type) {
        MovementType.entrada => entrada,
        MovementType.salida => salida,
        MovementType.ajuste => ajuste,
      };
}

/// Valida los datos comunes a todo movimiento antes de tocar el stock.
class MovementValidator {
  const MovementValidator._();

  static void validate({
    required MovementType type,
    required int quantity,
    required String reason,
    required String responsible,
    String? justification,
  }) {
    if (quantity < 0) {
      throw const DomainException(
        ErrorCodes.quantityNotPositive,
        'La cantidad no puede ser negativa.',
      );
    }
    if (type != MovementType.ajuste && quantity == 0) {
      throw const DomainException(
        ErrorCodes.quantityNotPositive,
        'La cantidad debe ser mayor que cero.',
      );
    }
    if (type == MovementType.ajuste &&
        (justification ?? '').trim().isEmpty) {
      throw const DomainException(
        ErrorCodes.justificationRequired,
        'El ajuste requiere una justificación.',
      );
    }
    if (reason.trim().isEmpty) {
      throw const DomainException(
        ErrorCodes.reasonRequired,
        'El motivo es obligatorio.',
      );
    }
    if (responsible.trim().isEmpty) {
      throw const DomainException(
        ErrorCodes.reasonRequired,
        'El responsable es obligatorio.',
      );
    }
  }
}
