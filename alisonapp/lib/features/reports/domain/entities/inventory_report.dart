import 'package:inventario/features/products/domain/entities/product.dart';

/// Resumen agregado del inventario para la pantalla de reportes.
class InventoryReport {
  const InventoryReport({
    required this.totalProducts,
    required this.activeProducts,
    required this.inactiveProducts,
    required this.totalUnits,
    required this.totalValue,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  final int totalProducts;
  final int activeProducts;
  final int inactiveProducts;
  final int totalUnits;

  /// Valor estimado del inventario: existencias por precio de compra.
  final double totalValue;
  final int lowStockCount;
  final int outOfStockCount;

  static InventoryReport fromProducts(List<Product> products) {
    int units = 0;
    double value = 0;
    int low = 0;
    int out = 0;
    int active = 0;

    for (final Product product in products) {
      units += product.stockActual;
      value += product.inventoryValue;
      if (product.active) {
        active++;
        if (product.stockStatus == StockStatus.outOfStock) {
          out++;
        } else if (product.stockStatus == StockStatus.low) {
          low++;
        }
      }
    }

    return InventoryReport(
      totalProducts: products.length,
      activeProducts: active,
      inactiveProducts: products.length - active,
      totalUnits: units,
      totalValue: value,
      lowStockCount: low,
      outOfStockCount: out,
    );
  }
}
