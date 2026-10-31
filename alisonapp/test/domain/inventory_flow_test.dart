import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/core/database/app_database.dart';
import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:drift/native.dart';
import 'package:inventario/features/inventory/data/repositories/drift_movement_repository.dart';
import 'package:inventario/features/inventory/domain/entities/movement.dart';
import 'package:inventario/features/inventory/domain/entities/movement_request.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/inventory/domain/usecases/register_movement_use_case.dart';
import 'package:inventario/features/products/data/repositories/drift_product_repository.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/domain/entities/product_draft.dart';
import 'package:inventario/features/products/domain/usecases/create_product_use_case.dart';
import 'package:inventario/features/products/domain/usecases/deactivate_product_use_case.dart';

void main() {
  late AppDatabase db;
  late DriftProductRepository products;
  late DriftMovementRepository movements;
  late int categoryId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    products = DriftProductRepository(db);
    movements = DriftMovementRepository(db);
    categoryId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: 'Abarrotes'),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Future<Product> createProduct({
    String code = 'P0000000001',
    int minStock = 5,
    int initialStock = 0,
  }) {
    return CreateProductUseCase(products)(
      ProductDraft(
        code: code,
        name: 'Producto $code',
        description: '',
        categoryId: categoryId,
        purchasePrice: 2,
        salePrice: 3,
        minStock: minStock,
        initialStock: initialStock,
        responsible: 'Ana',
      ),
    );
  }

  Future<Movement> register({
    required int productId,
    required MovementType type,
    required int quantity,
    String reason = 'Prueba',
    String? justification,
  }) {
    return RegisterMovementUseCase(movements)(
      MovementRequest(
        productId: productId,
        type: type,
        quantity: quantity,
        reason: reason,
        responsible: 'Ana',
        justification: justification,
      ),
    );
  }

  group('createProduct', () {
    test('guarda las existencias iniciales como movimiento de entrada', () async {
      final Product product = await createProduct(initialStock: 20);

      expect(product.stockActual, 20);

      final List<Movement> history = await movements.getMovements(
        productId: product.id,
      );
      expect(history, hasLength(1));
      expect(history.single.type, MovementType.entrada);
      expect(history.single.quantity, 20);
      expect(history.single.previousStock, 0);
      expect(history.single.resultingStock, 20);
      expect(history.single.reason, 'Existencias iniciales');
    });

    test('no registra movimiento cuando no hay existencias iniciales', () async {
      final Product product = await createProduct();
      expect(product.stockActual, 0);
      expect(await movements.countMovements(), 0);
    });

    test('rechaza un código duplicado', () async {
      await createProduct(code: 'P0000000001');
      expect(
        () => createProduct(code: 'P0000000001'),
        throwsA(
          isA<DomainException>().having((DomainException e) => e.code, 'code',
              ErrorCodes.codeDuplicated),
        ),
      );
    });
  });

  group('registerMovement · flujo de aceptación', () {
    test('entrada, salida, alerta y ajuste conservan el historial', () async {
      final Product product = await createProduct(minStock: 5);

      // Entrada de 20 unidades.
      final Movement entry = await register(
        productId: product.id,
        type: MovementType.entrada,
        quantity: 20,
        reason: 'Compra',
      );
      expect(entry.previousStock, 0);
      expect(entry.resultingStock, 20);

      // Salida de 16 unidades: quedan 4.
      final Movement exit = await register(
        productId: product.id,
        type: MovementType.salida,
        quantity: 16,
        reason: 'Venta',
      );
      expect(exit.previousStock, 20);
      expect(exit.resultingStock, 4);

      final Product? afterExit = await products.findById(product.id);
      expect(afterExit!.stockActual, 4);
      expect(afterExit.isLowStock, isTrue);

      // Intentar retirar 5 unidades con solo 4 disponibles debe fallar.
      await expectLater(
        register(
          productId: product.id,
          type: MovementType.salida,
          quantity: 5,
          reason: 'Venta',
        ),
        throwsA(
          isA<DomainException>().having((DomainException e) => e.code, 'code',
              ErrorCodes.insufficientStock),
        ),
      );

      // El stock no cambia tras el intento fallido.
      final Product? afterFailure = await products.findById(product.id);
      expect(afterFailure!.stockActual, 4);

      // Ajuste a 3 unidades con justificación.
      final Movement adjustment = await register(
        productId: product.id,
        type: MovementType.ajuste,
        quantity: 3,
        reason: 'Conteo físico',
        justification: 'Diferencia detectada en el conteo',
      );
      expect(adjustment.previousStock, 4);
      expect(adjustment.resultingStock, 3);

      final Product? finalProduct = await products.findById(product.id);
      expect(finalProduct!.stockActual, 3);
      expect(finalProduct.isLowStock, isTrue);

      final List<Movement> history =
          await movements.getMovements(productId: product.id);
      expect(history, hasLength(3));
      expect(
        history.map((Movement m) => m.type).toList(),
        <MovementType>[
          MovementType.ajuste,
          MovementType.salida,
          MovementType.entrada,
        ],
      );
    });

    test('el ajuste exige justificación', () async {
      final Product product = await createProduct();
      await expectLater(
        register(
          productId: product.id,
          type: MovementType.ajuste,
          quantity: 3,
          reason: 'Conteo físico',
        ),
        throwsA(
          isA<DomainException>().having((DomainException e) => e.code, 'code',
              ErrorCodes.justificationRequired),
        ),
      );
    });

    test('rechaza movimientos sobre productos desactivados', () async {
      final Product product = await createProduct(initialStock: 10);
      await DeactivateProductUseCase(products)(product.id);

      await expectLater(
        register(
          productId: product.id,
          type: MovementType.salida,
          quantity: 1,
        ),
        throwsA(
          isA<DomainException>().having((DomainException e) => e.code, 'code',
              ErrorCodes.productInactive),
        ),
      );
    });

    test('rechaza movimientos sobre productos inexistentes', () async {
      await expectLater(
        register(
          productId: 9999,
          type: MovementType.entrada,
          quantity: 1,
        ),
        throwsA(
          isA<DomainException>().having((DomainException e) => e.code, 'code',
              ErrorCodes.productNotFound),
        ),
      );
    });
  });

  group('atomicidad', () {
    test('una salida fallida no altera el stock ni deja movimiento', () async {
      final Product product = await createProduct(initialStock: 4);
      final int before = await movements.countMovements();

      await expectLater(
        register(
          productId: product.id,
          type: MovementType.salida,
          quantity: 10,
          reason: 'Venta',
        ),
        throwsA(isA<DomainException>()),
      );

      final Product? reloaded = await products.findById(product.id);
      expect(reloaded!.stockActual, 4);
      expect(await movements.countMovements(), before);
    });
  });

  group('desactivación', () {
    test('un producto con movimientos se desactiva sin borrar su historial',
        () async {
      final Product product = await createProduct(initialStock: 8);
      await DeactivateProductUseCase(products)(product.id);

      final Product? reloaded = await products.findById(product.id);
      expect(reloaded!.active, isFalse);
      expect(await movements.countMovements(), 1);

      final List<Product> active = await products.getProducts();
      expect(active, isEmpty);

      final List<Product> all =
          await products.getProducts(includeInactive: true);
      expect(all, hasLength(1));
    });
  });

  group('consultas y reportes', () {
    test('filtra el historial por tipo', () async {
      final Product product = await createProduct(initialStock: 10);
      await register(
        productId: product.id,
        type: MovementType.salida,
        quantity: 2,
        reason: 'Venta',
      );

      final List<Movement> entries = await movements.getMovements(
        productId: product.id,
        type: MovementType.entrada.code,
      );
      expect(entries, hasLength(1));

      final List<Movement> exits = await movements.getMovements(
        productId: product.id,
        type: MovementType.salida.code,
      );
      expect(exits, hasLength(1));
    });

    test('lista los productos con stock igual o inferior al mínimo', () async {
      await createProduct(code: 'P0000000001', minStock: 5, initialStock: 10);
      await createProduct(code: 'P0000000002', minStock: 5, initialStock: 4);

      final List<Product> lowStock = await products.getLowStockProducts();
      expect(lowStock, hasLength(1));
      expect(lowStock.single.code, 'P0000000002');
    });

    test('el historial se filtra por rango de fechas', () async {
      await createProduct(initialStock: 10);
      final DateTime future = DateTime.now().add(const Duration(days: 1));

      final List<Movement> upcoming = await movements.getMovements(
        from: future,
      );
      expect(upcoming, isEmpty);

      final List<Movement> all = await movements.getMovements(
        from: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(all, hasLength(1));
    });
  });
}
