import 'package:inventario/features/products/domain/entities/category.dart';

/// Producto del catálogo. [stockActual] es un valor derivado que solo cambia
/// mediante movimientos confirmados.
class Product {
  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.purchasePrice,
    required this.salePrice,
    required this.stockActual,
    required this.minStock,
    required this.active,
    this.photoPath,
    this.category,
  });

  final int id;
  final String code;
  final String name;
  final String description;
  final int categoryId;
  final double purchasePrice;
  final double salePrice;
  final int stockActual;
  final int minStock;
  final String? photoPath;
  final bool active;
  final Category? category;

  bool get isLowStock => stockActual <= minStock;

  bool get isOutOfStock => stockActual <= 0;

  double get inventoryValue => stockActual * purchasePrice;

  /// Estado del stock respecto al mínimo configurado.
  StockStatus get stockStatus {
    if (stockActual <= 0) {
      return StockStatus.outOfStock;
    }
    if (stockActual <= minStock) {
      return StockStatus.low;
    }
    return StockStatus.ok;
  }

  Product copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    int? categoryId,
    double? purchasePrice,
    double? salePrice,
    int? stockActual,
    int? minStock,
    String? photoPath,
    bool? active,
    Category? category,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      stockActual: stockActual ?? this.stockActual,
      minStock: minStock ?? this.minStock,
      photoPath: photoPath ?? this.photoPath,
      active: active ?? this.active,
      category: category ?? this.category,
    );
  }
}

enum StockStatus { ok, low, outOfStock }
