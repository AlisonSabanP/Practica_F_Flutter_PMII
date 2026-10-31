import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/domain/entities/product_draft.dart';
import 'package:inventario/features/products/domain/repositories/product_repository.dart';
import 'package:inventario/features/products/domain/services/product_validator.dart';

/// Crea un producto validando la unicidad del código y registrando el stock
/// inicial como movimiento de entrada.
class CreateProductUseCase {
  const CreateProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product> call(ProductDraft draft) async {
    ProductValidator.assertValid(draft);

    final String code = draft.code.trim();
    if (await _repository.isCodeTaken(code)) {
      throw DomainException(
        ErrorCodes.codeDuplicated,
        'Ya existe un producto con el código $code.',
      );
    }

    return _repository.createProduct(
      ProductDraft(
        code: code,
        name: draft.name.trim(),
        description: draft.description.trim(),
        categoryId: draft.categoryId,
        purchasePrice: draft.purchasePrice,
        salePrice: draft.salePrice,
        minStock: draft.minStock,
        photoPath: draft.photoPath,
        initialStock: draft.initialStock,
        active: draft.active,
        responsible: draft.responsible,
      ),
    );
  }
}
