import 'package:drift/drift.dart';
import 'package:inventario/core/database/app_database.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/settings/domain/repositories/demo_data_repository.dart';

/// Datos de demostración: 3 categorías y 15 productos con movimientos de
/// entrada coherentes. Se cargan una sola vez.
class DemoDataSeeder implements DemoDataRepository {
  DemoDataSeeder(this._db);

  final AppDatabase _db;

  static const String _responsible = 'Administrador';

  @override
  Future<bool> seedIfEmpty() {
    return _db.transaction(() async {
      final ProfileRow? profile = await (_db.select(_db.profiles)
            ..where((Profiles t) => t.id.equals(1)))
          .getSingleOrNull();

      final bool alreadySeeded = profile?.seeded ?? false;
      final int existing = (await _db.select(_db.products).get()).length;
      if (alreadySeeded || existing > 0) {
        return false;
      }

      final int bebidas = await _insertCategory('Bebidas');
      final int abarrotes = await _insertCategory('Abarrotes');
      final int aseo = await _insertCategory('Aseo y limpieza');

      await _insertProduct(
        code: 'P0000000001',
        name: 'Agua mineral 600 ml',
        description: 'Botella de agua sin gas de 600 ml',
        categoryId: bebidas,
        purchasePrice: 0.60,
        salePrice: 1.00,
        minStock: 12,
        initialStock: 48,
      );
      await _insertProduct(
        code: 'P0000000002',
        name: 'Gaseosa cola 1.5 L',
        description: 'Bebida gaseosa sabor cola de 1.5 litros',
        categoryId: bebidas,
        purchasePrice: 1.20,
        salePrice: 2.00,
        minStock: 10,
        initialStock: 36,
      );
      await _insertProduct(
        code: 'P0000000003',
        name: 'Jugo de naranja 1 L',
        description: 'Jugo natural pasteurizado de naranja',
        categoryId: bebidas,
        purchasePrice: 1.80,
        salePrice: 2.80,
        minStock: 8,
        initialStock: 24,
      );
      await _insertProduct(
        code: 'P0000000004',
        name: 'Café molido 250 g',
        description: 'Café tostado y molido en bolsa de 250 gramos',
        categoryId: bebidas,
        purchasePrice: 2.50,
        salePrice: 3.90,
        minStock: 6,
        initialStock: 18,
      );
      await _insertProduct(
        code: 'P0000000005',
        name: 'Té en caja 25 sobres',
        description: 'Caja de té negro con 25 sobres',
        categoryId: bebidas,
        purchasePrice: 1.10,
        salePrice: 1.90,
        minStock: 5,
        initialStock: 20,
      );
      await _insertProduct(
        code: 'P0000000006',
        name: 'Arroz blanco 1 kg',
        description: 'Arroz de grano largo en bolsa de 1 kilogramo',
        categoryId: abarrotes,
        purchasePrice: 0.90,
        salePrice: 1.40,
        minStock: 15,
        initialStock: 60,
      );
      await _insertProduct(
        code: 'P0000000007',
        name: 'Azúcar refinada 1 kg',
        description: 'Azúcar blanca refinada en bolsa de 1 kilogramo',
        categoryId: abarrotes,
        purchasePrice: 0.80,
        salePrice: 1.30,
        minStock: 15,
        initialStock: 50,
      );
      await _insertProduct(
        code: 'P0000000008',
        name: 'Aceite vegetal 1 L',
        description: 'Aceite de girasol en botella de 1 litro',
        categoryId: abarrotes,
        purchasePrice: 2.20,
        salePrice: 3.20,
        minStock: 10,
        initialStock: 30,
      );
      await _insertProduct(
        code: 'P0000000009',
        name: 'Fideos spaghetti 500 g',
        description: 'Pasta de sémola de trigo en paquete de 500 gramos',
        categoryId: abarrotes,
        purchasePrice: 0.70,
        salePrice: 1.20,
        minStock: 12,
        initialStock: 40,
      );
      await _insertProduct(
        code: 'P0000000010',
        name: 'Atún en aceite 170 g',
        description: 'Conserva de atún en aceite vegetal',
        categoryId: abarrotes,
        purchasePrice: 1.50,
        salePrice: 2.40,
        minStock: 8,
        initialStock: 26,
      );
      await _insertProduct(
        code: 'P0000000011',
        name: 'Leche en polvo 400 g',
        description: 'Leche entera en polvo fortificada',
        categoryId: abarrotes,
        purchasePrice: 3.10,
        salePrice: 4.50,
        minStock: 6,
        initialStock: 16,
      );
      await _insertProduct(
        code: 'P0000000012',
        name: 'Jabón de baño 110 g',
        description: 'Jabón de tocador con aroma neutro',
        categoryId: aseo,
        purchasePrice: 0.55,
        salePrice: 1.00,
        minStock: 10,
        initialStock: 42,
      );
      await _insertProduct(
        code: 'P0000000013',
        name: 'Detergente en polvo 900 g',
        description: 'Detergente para ropa en bolsa de 900 gramos',
        categoryId: aseo,
        purchasePrice: 2.40,
        salePrice: 3.60,
        minStock: 8,
        initialStock: 22,
      );
      await _insertProduct(
        code: 'P0000000014',
        name: 'Papel higiénico 4 rollos',
        description: 'Paquete de papel higiénico doble hoja',
        categoryId: aseo,
        purchasePrice: 1.60,
        salePrice: 2.50,
        minStock: 12,
        initialStock: 34,
      );
      await _insertProduct(
        code: 'P0000000015',
        name: 'Limpiador multiusos 1 L',
        description: 'Limpiador líquido para superficies lavables',
        categoryId: aseo,
        purchasePrice: 1.30,
        salePrice: 2.10,
        minStock: 6,
        initialStock: 12,
      );

      await _db.into(_db.profiles).insertOnConflictUpdate(
            const ProfilesCompanion(
              id: Value(1),
              responsibleName: Value(_responsible),
              storeName: Value('Bodega principal'),
              seeded: Value(true),
            ),
          );

      return true;
    });
  }

  Future<int> _insertCategory(String name) {
    return _db.into(_db.categories).insert(CategoriesCompanion.insert(name: name));
  }

  Future<void> _insertProduct({
    required String code,
    required String name,
    required String description,
    required int categoryId,
    required double purchasePrice,
    required double salePrice,
    required int minStock,
    required int initialStock,
  }) async {
    final int productId = await _db.into(_db.products).insert(
          ProductsCompanion.insert(
            code: code,
            name: name,
            description: Value(description),
            categoryId: categoryId,
            purchasePrice: Value(purchasePrice),
            salePrice: Value(salePrice),
            minStock: Value(minStock),
            stockActual: Value(initialStock),
          ),
        );

    await _db.into(_db.movements).insert(
          MovementsCompanion.insert(
            productId: productId,
            type: MovementType.entrada.code,
            quantity: initialStock,
            previousStock: 0,
            resultingStock: initialStock,
            reason: 'Existencias iniciales',
            responsible: _responsible,
            occurredAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        );
  }
}
