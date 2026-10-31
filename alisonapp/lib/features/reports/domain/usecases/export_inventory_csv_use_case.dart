import 'dart:io';

import 'package:inventario/core/utils/file_exporter.dart';
import 'package:inventario/core/utils/formatters.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/reports/domain/repositories/report_repository.dart';
import 'package:inventario/features/reports/domain/services/csv_builder.dart';

/// Exporta el inventario completo a un archivo CSV y lo comparte.
class ExportInventoryCsvUseCase {
  const ExportInventoryCsvUseCase(
    this._repository,
    this._exporter,
  );

  final ReportRepository _repository;
  final FileExporter _exporter;

  Future<File> call({DateTime? now}) async {
    final List<Product> products =
        await _repository.getInventorySnapshot(includeInactive: true);
    final String csv = CsvBuilder.inventoryCsv(products);
    final String stamp = Formatters.fileStamp(now ?? DateTime.now());
    return _exporter.writeTextFile(
      fileName: 'inventario_$stamp.csv',
      contents: csv,
    );
  }
}
