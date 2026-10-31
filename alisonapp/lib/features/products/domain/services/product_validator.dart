import 'package:inventario/core/error/domain_exception.dart';
import 'package:inventario/core/error/error_codes.dart';
import 'package:inventario/features/products/domain/entities/product_draft.dart';

/// Validaciones de producto aplicadas en el dominio, reutilizables por la UI.
class ProductValidator {
  const ProductValidator._();

  static final RegExp _codePattern = RegExp(r'^[A-Za-z0-9\-_]{3,32}$');

  static String? validateCode(String? value) {
    final String code = (value ?? '').trim();
    if (code.isEmpty) {
      return 'El código es obligatorio.';
    }
    if (!_codePattern.hasMatch(code)) {
      return 'Usa de 3 a 32 caracteres alfanuméricos, guion o guion bajo.';
    }
    return null;
  }

  static String? validateName(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'El nombre es obligatorio.';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    final double? parsed = parseDecimal(value);
    if (parsed == null) {
      return 'Ingresa un número válido.';
    }
    if (parsed < 0) {
      return 'El precio no puede ser negativo.';
    }
    return null;
  }

  static String? validateMinStock(String? value) {
    final int? parsed = int.tryParse((value ?? '').trim());
    if (parsed == null) {
      return 'Ingresa un número entero.';
    }
    if (parsed < 0) {
      return 'El stock mínimo no puede ser negativo.';
    }
    return null;
  }

  static String? validateInitialStock(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return null;
    }
    final int? parsed = int.tryParse((value ?? '').trim());
    if (parsed == null) {
      return 'Ingresa un número entero.';
    }
    if (parsed < 0) {
      return 'El stock inicial no puede ser negativo.';
    }
    return null;
  }

  /// Acepta coma o punto como separador decimal.
  static double? parseDecimal(String? value) {
    final String raw = (value ?? '').trim().replaceAll(',', '.');
    if (raw.isEmpty) {
      return null;
    }
    return double.tryParse(raw);
  }

  /// Lanza si el borrador no cumple las reglas de negocio del producto.
  static void assertValid(ProductDraft draft) {
    if (validateCode(draft.code) != null) {
      throw const DomainException(
        ErrorCodes.codeRequired,
        'El código del producto no es válido.',
      );
    }
    if (validateName(draft.name) != null) {
      throw const DomainException(
        ErrorCodes.nameRequired,
        'El nombre del producto es obligatorio.',
      );
    }
    if (draft.purchasePrice < 0 || draft.salePrice < 0) {
      throw const DomainException(
        ErrorCodes.priceInvalid,
        'Los precios no pueden ser negativos.',
      );
    }
    if (draft.minStock < 0) {
      throw const DomainException(
        ErrorCodes.minStockInvalid,
        'El stock mínimo no puede ser negativo.',
      );
    }
    if (draft.initialStock < 0) {
      throw const DomainException(
        ErrorCodes.minStockInvalid,
        'El stock inicial no puede ser negativo.',
      );
    }
  }
}
