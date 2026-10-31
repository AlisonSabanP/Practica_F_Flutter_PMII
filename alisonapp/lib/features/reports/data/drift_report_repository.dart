import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/domain/repositories/product_repository.dart';
import 'package:inventario/features/reports/domain/repositories/report_repository.dart';

/// Reportes construidos sobre el repositorio de productos.
class DriftReportRepository implements ReportRepository {
  DriftReportRepository(this._products);

  final ProductRepository _products;

  @override
  Future<List<Product>> getInventorySnapshot({bool includeInactive = true}) {
    return _products.getProducts(includeInactive: includeInactive);
  }
}
