import 'package:inventario/features/products/domain/entities/product.dart';

/// Construye documentos CSV a partir del catálogo. Lógica pura, sin acceso a
/// almacenamiento ni a la interfaz.
class CsvBuilder {
  const CsvBuilder._();

  static const String separator = ',';

  static const List<String> inventoryHeaders = <String>[
    'codigo',
    'nombre',
    'categoria',
    'descripcion',
    'precio_compra',
    'precio_venta',
    'stock_actual',
    'stock_minimo',
    'estado_stock',
    'activo',
    'valor_inventario',
  ];

  /// Escapa un campo según RFC 4180.
  static String escape(String value) {
    final bool needsQuotes = value.contains(separator) ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    if (!needsQuotes) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }

  static String inventoryCsv(List<Product> products) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(inventoryHeaders.join(separator));

    for (final Product product in products) {
      buffer.writeln(
        <String>[
          escape(product.code),
          escape(product.name),
          escape(product.category?.name ?? 'Sin categoría'),
          escape(product.description),
          product.purchasePrice.toStringAsFixed(2),
          product.salePrice.toStringAsFixed(2),
          product.stockActual.toString(),
          product.minStock.toString(),
          product.stockStatus.name,
          product.active ? 'si' : 'no',
          product.inventoryValue.toStringAsFixed(2),
        ].join(separator),
      );
    }

    return buffer.toString();
  }
}
