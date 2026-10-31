import 'package:inventario/features/products/domain/entities/category.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/domain/entities/product_draft.dart';

/// Contrato de acceso a productos y categorías.
abstract class ProductRepository {
  Stream<List<Product>> watchProducts({bool includeInactive = false});

  Future<List<Product>> getProducts({bool includeInactive = false});

  Stream<List<Product>> watchLowStockProducts();

  Future<List<Product>> getLowStockProducts();

  Future<Product?> findById(int id);

  Future<Product?> findByCode(String code);

  Future<List<Category>> getCategories();

  Stream<List<Category>> watchCategories();

  /// Crea el producto y, si el borrador trae existencias iniciales, registra el
  /// movimiento de entrada dentro de la misma transacción.
  Future<Product> createProduct(ProductDraft draft);

  Future<Product> updateProduct(ProductDraft draft);

  Future<void> deactivateProduct(int id);

  Future<void> reactivateProduct(int id);

  /// Verifica si existe un producto con [code]. [excludeId] permite ignorar el
  /// propio producto durante una edición.
  Future<bool> isCodeTaken(String code, {int? excludeId});

  Future<bool> hasMovements(int productId);
}
