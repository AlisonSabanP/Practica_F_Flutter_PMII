import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/domain/repositories/product_repository.dart';

/// Obtiene productos con existencias iguales o inferiores al stock mínimo.
class GetLowStockProductsUseCase {
  const GetLowStockProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call() => _repository.getLowStockProducts();
}
