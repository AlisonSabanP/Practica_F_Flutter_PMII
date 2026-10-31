import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/inventory/domain/entities/stock_change.dart';
import 'package:inventario/features/inventory/domain/services/stock_calculator.dart';

void main() {
  group('StockCalculator.apply · entrada', () {
    test('suma la cantidad al stock actual', () {
      final StockChange change = StockCalculator.apply(
        type: MovementType.entrada,
        quantity: 20,
        currentStock: 5,
      );

      expect(change.previousStock, 5);
      expect(change.resultingStock, 25);
      expect(change.delta, 20);
    });

    test('rechaza cantidad cero', () {
      expect(
        () => StockCalculator.apply(
          type: MovementType.entrada,
          quantity: 0,
          currentStock: 5,
        ),
        throwsA(
          isA<DomainException>()
              .having((DomainException e) => e.code, 'code',
                  ErrorCodes.quantityNotPositive),
        ),
      );
    });

    test('rechaza cantidad negativa', () {
      expect(
        () => StockCalculator.apply(
          type: MovementType.entrada,
          quantity: -3,
          currentStock: 5,
        ),
        throwsA(isA<DomainException>()),
      );
    });
  });

  group('StockCalculator.apply · salida', () {
    test('descuenta la cantidad del stock actual', () {
      final StockChange change = StockCalculator.apply(
        type: MovementType.salida,
        quantity: 16,
        currentStock: 20,
      );

      expect(change.previousStock, 20);
      expect(change.resultingStock, 4);
      expect(change.delta, -16);
    });

    test('permite dejar el stock en cero', () {
      final StockChange change = StockCalculator.apply(
        type: MovementType.salida,
        quantity: 20,
        currentStock: 20,
      );

      expect(change.resultingStock, 0);
    });

    test('rechaza salida superior al stock disponible', () {
      expect(
        () => StockCalculator.apply(
          type: MovementType.salida,
          quantity: 5,
          currentStock: 4,
        ),
        throwsA(
          isA<DomainException>().having((DomainException e) => e.code, 'code',
              ErrorCodes.insufficientStock),
        ),
      );
    });

    test('rechaza cantidad cero', () {
      expect(
        () => StockCalculator.apply(
          type: MovementType.salida,
          quantity: 0,
          currentStock: 10,
        ),
        throwsA(isA<DomainException>()),
      );
    });
  });

  group('StockCalculator.apply · ajuste', () {
    test('fija el stock en la cantidad contada', () {
      final StockChange change = StockCalculator.apply(
        type: MovementType.ajuste,
        quantity: 3,
        currentStock: 4,
        justification: 'Conteo físico del cierre de mes',
      );

      expect(change.previousStock, 4);
      expect(change.resultingStock, 3);
      expect(change.delta, -1);
    });

    test('permite ajustar a cero con justificación', () {
      final StockChange change = StockCalculator.apply(
        type: MovementType.ajuste,
        quantity: 0,
        currentStock: 7,
        justification: 'Merma total registrada',
      );

      expect(change.resultingStock, 0);
    });

    test('exige justificación no vacía', () {
      expect(
        () => StockCalculator.apply(
          type: MovementType.ajuste,
          quantity: 3,
          currentStock: 4,
          justification: '   ',
        ),
        throwsA(
          isA<DomainException>().having((DomainException e) => e.code, 'code',
              ErrorCodes.justificationRequired),
        ),
      );
    });
  });
}
