import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/reports/domain/entities/inventory_report.dart';
import 'package:inventario/features/reports/domain/repositories/report_repository.dart';

/// Calcula el resumen del inventario y las alertas de stock.
class BuildInventoryReportUseCase {
  const BuildInventoryReportUseCase(this._repository);

  final ReportRepository _repository;

  Future<InventoryReport> call({bool includeInactive = true}) async {
    final List<Product> products =
        await _repository.getInventorySnapshot(includeInactive: includeInactive);
    return InventoryReport.fromProducts(products);
  }
}
