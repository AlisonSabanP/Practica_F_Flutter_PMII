import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/domain/repositories/product_repository.dart';

/// Busca un producto por su código único. Devuelve null si no existe.
class FindProductByCodeUseCase {
  const FindProductByCodeUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product?> call(String code) {
    final String normalized = code.trim();
    if (normalized.isEmpty) {
      throw const DomainException(
        ErrorCodes.codeRequired,
        'El código no puede estar vacío.',
      );
    }
    return _repository.findByCode(normalized);
  }
}

/// Filtra productos por texto en código, nombre o descripción.
class SearchProductsUseCase {
  const SearchProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call(String query, {bool includeInactive = false}) async {
    final List<Product> products =
        await _repository.getProducts(includeInactive: includeInactive);
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return products;
    }
    return products
        .where((Product product) =>
            product.code.toLowerCase().contains(needle) ||
            product.name.toLowerCase().contains(needle) ||
            product.description.toLowerCase().contains(needle))
        .toList(growable: false);
  }
}
