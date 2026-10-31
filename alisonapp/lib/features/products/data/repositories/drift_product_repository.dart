import 'package:drift/drift.dart';
import 'package:inventario/core/database/app_database.dart';
import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/inventory/domain/entities/stock_change.dart';
import 'package:inventario/features/inventory/domain/services/stock_calculator.dart';
import 'package:inventario/features/products/data/product_mapper.dart';
import 'package:inventario/features/products/domain/entities/category.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/domain/entities/product_draft.dart';
import 'package:inventario/features/products/domain/repositories/product_repository.dart';

/// Repositorio de productos y categorías sobre Drift.
class DriftProductRepository implements ProductRepository {
  DriftProductRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Product>> watchProducts({bool includeInactive = false}) {
    return _selectProducts(includeInactive: includeInactive).watch().asyncMap(_hydrate);
  }

  @override
  Future<List<Product>> getProducts({bool includeInactive = false}) async {
    final List<ProductRow> rows =
        await _selectProducts(includeInactive: includeInactive).get();
    return _hydrate(rows);
  }

  @override
  Stream<List<Product>> watchLowStockProducts() =>
      _lowStockQuery().watch().asyncMap(_hydrate);

  @override
  Future<List<Product>> getLowStockProducts() async {
    final List<ProductRow> rows = await _lowStockQuery().get();
    return _hydrate(rows);
  }

  @override
  Future<Product?> findById(int id) async {
    final ProductRow? row = await (_db.select(_db.products)
          ..where((Products t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _hydrateSingle(row);
  }

  @override
  Future<Product?> findByCode(String code) async {
    final ProductRow? row = await (_db.select(_db.products)
          ..where((Products t) => t.code.equals(code)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _hydrateSingle(row);
  }

  @override
  Future<List<Category>> getCategories() async {
    final List<CategoryRow> rows = await (_db.select(_db.categories)
          ..orderBy(<OrderClauseGenerator<$CategoriesTable>>[
            (Categories t) => OrderingTerm.asc(t.name),
          ]))
        .get();
    return rows.map(CategoryMapper.fromRow).toList(growable: false);
  }

  @override
  Stream<List<Category>> watchCategories() {
    return (_db.select(_db.categories)
          ..orderBy(<OrderClauseGenerator<$CategoriesTable>>[
            (Categories t) => OrderingTerm.asc(t.name),
          ]))
        .watch()
        .map((List<CategoryRow> rows) =>
            rows.map(CategoryMapper.fromRow).toList(growable: false));
  }

  @override
  Future<Product> createProduct(ProductDraft draft) {
    return _db.transaction(() async {
      if (await isCodeTaken(draft.code)) {
        throw DomainException(
          ErrorCodes.codeDuplicated,
          'Ya existe un producto con el código ${draft.code}.',
        );
      }

      final int productId = await _db.into(_db.products).insert(
            ProductsCompanion.insert(
              code: draft.code,
              name: draft.name,
              description: Value(draft.description),
              categoryId: draft.categoryId,
              purchasePrice: Value(draft.purchasePrice),
              salePrice: Value(draft.salePrice),
              minStock: Value(draft.minStock),
              photoPath: Value(draft.photoPath),
              active: Value(draft.active),
            ),
          );

      // Las existencias iniciales nunca se escriben directo: se registran como
      // movimiento de entrada dentro de la misma transacción.
      if (draft.initialStock > 0) {
        final StockChange change = StockCalculator.apply(
          type: MovementType.entrada,
          quantity: draft.initialStock,
          currentStock: 0,
        );
        await _db.into(_db.movements).insert(
              MovementsCompanion.insert(
                productId: productId,
                type: MovementType.entrada.code,
                quantity: draft.initialStock,
                previousStock: change.previousStock,
                resultingStock: change.resultingStock,
                reason: 'Existencias iniciales',
                responsible: draft.responsible.trim().isEmpty
                    ? 'Sin responsable'
                    : draft.responsible.trim(),
                occurredAt: DateTime.now(),
              ),
            );
        await (_db.update(_db.products)..where((Products t) => t.id.equals(productId)))
            .write(ProductsCompanion(stockActual: Value(change.resultingStock)));
      }

      final ProductRow row = await (_db.select(_db.products)
            ..where((Products t) => t.id.equals(productId)))
          .getSingle();
      return _hydrateSingle(row);
    });
  }

  @override
  Future<Product> updateProduct(ProductDraft draft) async {
    final int id = draft.id!;
    await (_db.update(_db.products)..where((Products t) => t.id.equals(id)))
        .write(
      ProductsCompanion(
        code: Value(draft.code),
        name: Value(draft.name),
        description: Value(draft.description),
        categoryId: Value(draft.categoryId),
        purchasePrice: Value(draft.purchasePrice),
        salePrice: Value(draft.salePrice),
        minStock: Value(draft.minStock),
        photoPath: Value(draft.photoPath),
        active: Value(draft.active),
      ),
    );
    final ProductRow row = await (_db.select(_db.products)
          ..where((Products t) => t.id.equals(id)))
        .getSingle();
    return _hydrateSingle(row);
  }

  @override
  Future<void> deactivateProduct(int id) async {
    await (_db.update(_db.products)..where((Products t) => t.id.equals(id)))
        .write(const ProductsCompanion(active: Value(false)));
  }

  @override
  Future<void> reactivateProduct(int id) async {
    await (_db.update(_db.products)..where((Products t) => t.id.equals(id)))
        .write(const ProductsCompanion(active: Value(true)));
  }

  @override
  Future<bool> isCodeTaken(String code, {int? excludeId}) async {
    final SimpleSelectStatement<$ProductsTable, ProductRow> query =
        _db.select(_db.products)..where((Products t) => t.code.equals(code));
    if (excludeId != null) {
      query.where((Products t) => t.id.equals(excludeId).not());
    }
    final ProductRow? row = await query.getSingleOrNull();
    return row != null;
  }

  @override
  Future<bool> hasMovements(int productId) async {
    final MovementRow? row = await (_db.select(_db.movements)
          ..where((Movements t) => t.productId.equals(productId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  SimpleSelectStatement<$ProductsTable, ProductRow> _selectProducts({
    required bool includeInactive,
  }) {
    final SimpleSelectStatement<$ProductsTable, ProductRow> query =
        _db.select(_db.products);
    if (!includeInactive) {
      query.where((Products t) => t.active.equals(true));
    }
    query.orderBy(<OrderClauseGenerator<$ProductsTable>>[
      (Products t) => OrderingTerm.asc(t.name),
    ]);
    return query;
  }

  SimpleSelectStatement<$ProductsTable, ProductRow> _lowStockQuery() {
    return _db.select(_db.products)
      ..where((Products t) =>
          t.active.equals(true) & t.stockActual.isSmallerOrEqual(t.minStock))
      ..orderBy(<OrderClauseGenerator<$ProductsTable>>[
        (Products t) => OrderingTerm.asc(t.stockActual),
      ]);
  }

  Future<List<Product>> _hydrate(List<ProductRow> rows) async {
    if (rows.isEmpty) {
      return const <Product>[];
    }
    final Map<int, CategoryRow> categories = await _categoriesById();
    return rows
        .map((ProductRow row) => ProductMapper.fromRow(
              row,
              categoryRow: categories[row.categoryId],
            ))
        .toList(growable: false);
  }

  Future<Product> _hydrateSingle(ProductRow row) async {
    final Map<int, CategoryRow> categories = await _categoriesById();
    return ProductMapper.fromRow(row, categoryRow: categories[row.categoryId]);
  }

  Future<Map<int, CategoryRow>> _categoriesById() async {
    final List<CategoryRow> rows = await _db.select(_db.categories).get();
    return <int, CategoryRow>{
      for (final CategoryRow row in rows) row.id: row,
    };
  }
}
