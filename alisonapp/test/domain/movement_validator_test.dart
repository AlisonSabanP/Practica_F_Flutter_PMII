import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/inventory/domain/services/movement_validator.dart';

void main() {
  group('MovementValidator.validate', () {
    test('acepta una entrada válida', () {
      expect(
        () => MovementValidator.validate(
          type: MovementType.entrada,
          quantity: 5,
          reason: 'Compra',
          responsible: 'Ana',
        ),
        returnsNormally,
      );
    });

    test('rechaza entrada con cantidad cero', () {
      expect(
        () => MovementValidator.validate(
          type: MovementType.entrada,
          quantity: 0,
          reason: 'Compra',
          responsible: 'Ana',
        ),
        throwsA(
          isA<DomainException>().having((DomainException e) => e.code, 'code',
              ErrorCodes.quantityNotPositive),
        ),
      );
    });

    test('rechaza salida con cantidad cero', () {
      expect(
        () => MovementValidator.validate(
          type: MovementType.salida,
          quantity: 0,
          reason: 'Venta',
          responsible: 'Ana',
        ),
        throwsA(isA<DomainException>()),
      );
    });

    test('rechaza motivo vacío', () {
      expect(
        () => MovementValidator.validate(
          type: MovementType.entrada,
          quantity: 5,
          reason: '  ',
          responsible: 'Ana',
        ),
        throwsA(
          isA<DomainException>().having((DomainException e) => e.code, 'code',
              ErrorCodes.reasonRequired),
        ),
      );
    });

    test('rechaza responsable vacío', () {
      expect(
        () => MovementValidator.validate(
          type: MovementType.entrada,
          quantity: 5,
          reason: 'Compra',
          responsible: '   ',
        ),
        throwsA(isA<DomainException>()),
      );
    });

    test('rechaza ajuste sin justificación', () {
      expect(
        () => MovementValidator.validate(
          type: MovementType.ajuste,
          quantity: 3,
          reason: 'Conteo físico',
          responsible: 'Ana',
        ),
        throwsA(
          isA<DomainException>().having((DomainException e) => e.code, 'code',
              ErrorCodes.justificationRequired),
        ),
      );
    });

    test('acepta ajuste con justificación', () {
      expect(
        () => MovementValidator.validate(
          type: MovementType.ajuste,
          quantity: 3,
          reason: 'Conteo físico',
          responsible: 'Ana',
          justification: 'Diferencia detectada en el conteo',
        ),
        returnsNormally,
      );
    });

    test('los motivos sugeridos cubren cada tipo', () {
      for (final MovementType type in MovementType.values) {
        expect(MovementReasons.forType(type), isNotEmpty);
      }
    });
  });
}
