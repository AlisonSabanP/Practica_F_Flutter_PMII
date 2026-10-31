import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/features/products/domain/entities/product_draft.dart';
import 'package:inventario/features/products/domain/services/product_validator.dart';

void main() {
  ProductDraft draft({
    String code = 'P1234567890',
    String name = 'Producto',
    double purchasePrice = 1,
    double salePrice = 2,
    int minStock = 5,
    int initialStock = 0,
  }) {
    return ProductDraft(
      code: code,
      name: name,
      description: '',
      categoryId: 1,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      minStock: minStock,
      initialStock: initialStock,
    );
  }

  group('ProductValidator · campos', () {
    test('código obligatorio', () {
      expect(ProductValidator.validateCode(''), isNotNull);
    });

    test('código con formato inválido', () {
      expect(ProductValidator.validateCode('ab'), isNotNull);
      expect(ProductValidator.validateCode('código con espacios'), isNotNull);
    });

    test('código válido', () {
      expect(ProductValidator.validateCode('ABC-123_x'), isNull);
    });

    test('nombre obligatorio', () {
      expect(ProductValidator.validateName('   '), isNotNull);
      expect(ProductValidator.validateName('Arroz'), isNull);
    });

    test('precios numéricos y no negativos', () {
      expect(ProductValidator.validatePrice('abc'), isNotNull);
      expect(ProductValidator.validatePrice('-1'), isNotNull);
      expect(ProductValidator.validatePrice('12,50'), isNull);
      expect(ProductValidator.validatePrice('12.50'), isNull);
    });

    test('stock mínimo entero no negativo', () {
      expect(ProductValidator.validateMinStock('x'), isNotNull);
      expect(ProductValidator.validateMinStock('-2'), isNotNull);
      expect(ProductValidator.validateMinStock('5'), isNull);
    });

    test('existencias iniciales opcionales', () {
      expect(ProductValidator.validateInitialStock(''), isNull);
      expect(ProductValidator.validateInitialStock('abc'), isNotNull);
      expect(ProductValidator.validateInitialStock('-1'), isNotNull);
      expect(ProductValidator.validateInitialStock('20'), isNull);
    });

    test('parseDecimal acepta coma o punto', () {
      expect(ProductValidator.parseDecimal('1,5'), 1.5);
      expect(ProductValidator.parseDecimal('1.5'), 1.5);
      expect(ProductValidator.parseDecimal(''), isNull);
    });
  });

  group('ProductValidator.assertValid', () {
    test('acepta un borrador correcto', () {
      expect(() => ProductValidator.assertValid(draft()), returnsNormally);
    });

    test('rechaza precio negativo', () {
      expect(
        () => ProductValidator.assertValid(draft(purchasePrice: -1)),
        throwsA(isA<DomainException>()),
      );
    });

    test('rechaza stock mínimo negativo', () {
      expect(
        () => ProductValidator.assertValid(draft(minStock: -1)),
        throwsA(isA<DomainException>()),
      );
    });

    test('rechaza existencias iniciales negativas', () {
      expect(
        () => ProductValidator.assertValid(draft(initialStock: -1)),
        throwsA(isA<DomainException>()),
      );
    });
  });
}
