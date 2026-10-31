import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/domain/entities/product_draft.dart';
import 'package:inventario/features/products/domain/repositories/product_repository.dart';
import 'package:inventario/features/products/domain/services/product_validator.dart';

/// Actualiza un producto existente. El stock no se modifica por esta vía:
/// solo cambia mediante movimientos de inventario.
class UpdateProductUseCase {
  const UpdateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product> call(ProductDraft draft) async {
    if (draft.id == null) {
      throw const DomainException(
        ErrorCodes.productNotFound,
        'No se indicó el producto a actualizar.',
      );
    }

    ProductValidator.assertValid(draft);

    final String code = draft.code.trim();
    if (await _repository.isCodeTaken(code, excludeId: draft.id)) {
      throw DomainException(
        ErrorCodes.codeDuplicated,
        'Ya existe otro producto con el código $code.',
      );
    }

    return _repository.updateProduct(
      ProductDraft(
        id: draft.id,
        code: code,
        name: draft.name.trim(),
        description: draft.description.trim(),
        categoryId: draft.categoryId,
        purchasePrice: draft.purchasePrice,
        salePrice: draft.salePrice,
        minStock: draft.minStock,
        photoPath: draft.photoPath,
        active: draft.active,
      ),
    );
  }
}
