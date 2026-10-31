import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/products/domain/repositories/product_repository.dart';

/// Desactiva un producto. Nunca se elimina físicamente si tiene movimientos.
class DeactivateProductUseCase {
  const DeactivateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(int productId) async {
    final bool hasMovements = await _repository.hasMovements(productId);
    if (hasMovements) {
      // El producto conserva su historial: solo se marca como inactivo.
      await _repository.deactivateProduct(productId);
      return;
    }
    await _repository.deactivateProduct(productId);
  }
}

/// Reactiva un producto previamente desactivado.
class ReactivateProductUseCase {
  const ReactivateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(int productId) async {
    final product = await _repository.findById(productId);
    if (product == null) {
      throw const DomainException(
        ErrorCodes.productNotFound,
        'El producto no existe.',
      );
    }
    await _repository.reactivateProduct(productId);
  }
}
