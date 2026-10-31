import 'package:inventario/features/products/domain/entities/product.dart';

/// Contrato de consultas agregadas del inventario.
abstract class ReportRepository {
  Future<List<Product>> getInventorySnapshot({bool includeInactive = true});
}
