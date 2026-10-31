import 'package:drift/drift.dart';
import 'package:inventario/core/database/app_database.dart';
import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/inventory/data/movement_mapper.dart';
import 'package:inventario/features/inventory/domain/entities/movement.dart';
import 'package:inventario/features/inventory/domain/entities/movement_request.dart';
import 'package:inventario/features/inventory/domain/entities/stock_change.dart';
import 'package:inventario/features/inventory/domain/repositories/movement_repository.dart';
import 'package:inventario/features/inventory/domain/services/stock_calculator.dart';

/// Repositorio de movimientos sobre Drift.
///
/// El registro del movimiento y la actualización del stock se ejecutan dentro
/// de una única transacción para que la operación sea atómica.
class DriftMovementRepository implements MovementRepository {
  DriftMovementRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Movement> registerMovement(MovementRequest request) {
    return _db.transaction(() async {
      final ProductRow? product =
          await (_db.select(_db.products)..where((Products t) => t.id.equals(request.productId)))
              .getSingleOrNull();

      if (product == null) {
        throw const DomainException(
          ErrorCodes.productNotFound,
          'El producto ya no existe.',
        );
      }
      if (!product.active) {
        throw const DomainException(
          ErrorCodes.productInactive,
          'El producto está desactivado y no admite movimientos.',
        );
      }

      final StockChange change = StockCalculator.apply(
        type: request.type,
        quantity: request.quantity,
        currentStock: product.stockActual,
        justification: request.justification,
      );

      final DateTime now = DateTime.now();

      // Guarda el movimiento antes de actualizar el stock. Si algo falla, la
      // transacción revierte ambas escrituras.
      final int movementId = await _db.into(_db.movements).insert(
            MovementsCompanion.insert(
              productId: product.id,
              type: request.type.code,
              quantity: request.quantity,
              previousStock: change.previousStock,
              resultingStock: change.resultingStock,
              reason: request.reason,
              responsible: request.responsible,
              occurredAt: now,
            ),
          );

      await (_db.update(_db.products)..where((Products t) => t.id.equals(product.id)))
          .write(ProductsCompanion(stockActual: Value(change.resultingStock)));

      return Movement(
        id: movementId,
        productId: product.id,
        type: request.type,
        quantity: request.quantity,
        previousStock: change.previousStock,
        resultingStock: change.resultingStock,
        reason: request.reason,
        responsible: request.responsible,
        dateTime: now,
        productCode: product.code,
        productName: product.name,
      );
    });
  }

  @override
  Future<List<Movement>> getMovements({
    int? productId,
    String? type,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final List<MovementRow> rows = await _query(
      productId: productId,
      type: type,
      from: from,
      to: to,
      limit: limit,
    ).get();
    return _hydrate(rows);
  }

  @override
  Stream<List<Movement>> watchMovements({
    int? productId,
    String? type,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) {
    return _query(
      productId: productId,
      type: type,
      from: from,
      to: to,
      limit: limit,
    ).watch().asyncMap(_hydrate);
  }

  @override
  Future<int> countMovements() async {
    final Expression<int> count = _db.movements.id.count();
    final int? total = await (_db.selectOnly(_db.movements)..addColumns(<Expression<Object>>[count]))
        .map((TypedResult row) => row.read(count))
        .getSingle();
    return total ?? 0;
  }

  SimpleSelectStatement<$MovementsTable, MovementRow> _query({
    int? productId,
    String? type,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) {
    final SimpleSelectStatement<$MovementsTable, MovementRow> query =
        _db.select(_db.movements);

    if (productId != null) {
      query.where((Movements t) => t.productId.equals(productId));
    }
    if (type != null) {
      query.where((Movements t) => t.type.equals(type));
    }
    if (from != null) {
      query.where((Movements t) => t.occurredAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((Movements t) => t.occurredAt.isSmallerOrEqualValue(to));
    }

    query.orderBy(<OrderClauseGenerator<$MovementsTable>>[
      (Movements t) => OrderingTerm.desc(t.occurredAt),
      (Movements t) => OrderingTerm.desc(t.id),
    ]);

    if (limit != null) {
      query.limit(limit);
    }
    return query;
  }

  Future<List<Movement>> _hydrate(List<MovementRow> rows) async {
    if (rows.isEmpty) {
      return const <Movement>[];
    }

    final Set<int> productIds =
        rows.map((MovementRow row) => row.productId).toSet();
    final List<ProductRow> products = await (_db.select(_db.products)
          ..where((Products t) => t.id.isIn(productIds)))
        .get();
    final Map<int, ProductRow> byId = <int, ProductRow>{
      for (final ProductRow product in products) product.id: product,
    };

    return rows
        .map((MovementRow row) =>
            MovementMapper.fromRow(row, productRow: byId[row.productId]))
        .toList(growable: false);
  }
}
