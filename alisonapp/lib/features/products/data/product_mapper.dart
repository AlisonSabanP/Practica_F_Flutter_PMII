import 'package:inventario/core/database/app_database.dart';
import 'package:inventario/features/products/domain/entities/category.dart';
import 'package:inventario/features/products/domain/entities/product.dart';

/// Conversión entre filas de Drift y entidades de dominio.
class ProductMapper {
  const ProductMapper._();

  static Product fromRow(ProductRow row, {CategoryRow? categoryRow}) {
    return Product(
      id: row.id,
      code: row.code,
      name: row.name,
      description: row.description,
      categoryId: row.categoryId,
      purchasePrice: row.purchasePrice,
      salePrice: row.salePrice,
      stockActual: row.stockActual,
      minStock: row.minStock,
      photoPath: row.photoPath,
      active: row.active,
      category: categoryRow == null ? null : CategoryMapper.fromRow(categoryRow),
    );
  }
}

class CategoryMapper {
  const CategoryMapper._();

  static Category fromRow(CategoryRow row) =>
      Category(id: row.id, name: row.name);
}
