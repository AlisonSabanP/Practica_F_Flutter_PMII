import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/inventory/domain/entities/stock_change.dart';

/// Reglas de inventario puras. No depende de widgets ni de la base de datos.
class StockCalculator {
  const StockCalculator._();

  /// Cota superior defensiva para evitar desbordes por entradas absurdas.
  static const int maxQuantity = 1000000;

  /// Aplica un movimiento sobre un stock conocido y devuelve el nuevo estado.
  ///
  /// Para entrada y salida, [quantity] es la cantidad que entra o sale.
  /// Para ajuste, [quantity] es la cantidad contada y pasa a ser el stock.
  static StockChange apply({
    required MovementType type,
    required int quantity,
    required int currentStock,
    String? justification,
  }) {
    if (quantity < 0) {
      throw const DomainException(
        ErrorCodes.quantityNotPositive,
        'La cantidad no puede ser negativa.',
      );
    }
    if (quantity > maxQuantity) {
      throw const DomainException(
        ErrorCodes.quantityNotPositive,
        'La cantidad supera el máximo permitido.',
      );
    }

    switch (type) {
      case MovementType.entrada:
        if (quantity == 0) {
          throw const DomainException(
            ErrorCodes.quantityNotPositive,
            'La cantidad de entrada debe ser mayor que cero.',
          );
        }
        return StockChange(
          previousStock: currentStock,
          resultingStock: currentStock + quantity,
        );

      case MovementType.salida:
        if (quantity == 0) {
          throw const DomainException(
            ErrorCodes.quantityNotPositive,
            'La cantidad de salida debe ser mayor que cero.',
          );
        }
        if (quantity > currentStock) {
          throw DomainException(
            ErrorCodes.insufficientStock,
            'Stock insuficiente: solo hay $currentStock unidades disponibles.',
          );
        }
        return StockChange(
          previousStock: currentStock,
          resultingStock: currentStock - quantity,
        );

      case MovementType.ajuste:
        if ((justification ?? '').trim().isEmpty) {
          throw const DomainException(
            ErrorCodes.justificationRequired,
            'El ajuste requiere una justificación.',
          );
        }
        return StockChange(previousStock: currentStock, resultingStock: quantity);
    }
  }
}
