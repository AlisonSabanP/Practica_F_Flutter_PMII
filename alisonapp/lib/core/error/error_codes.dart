/// Códigos de error estables usados por el dominio y la capa de datos.
class ErrorCodes {
  const ErrorCodes._();

  static const String quantityNotPositive = 'quantity_not_positive';
  static const String insufficientStock = 'insufficient_stock';
  static const String reasonRequired = 'reason_required';
  static const String justificationRequired = 'justification_required';
  static const String codeDuplicated = 'code_duplicated';
  static const String codeRequired = 'code_required';
  static const String productNotFound = 'product_not_found';
  static const String productInactive = 'product_inactive';
  static const String productHasMovements = 'product_has_movements';
  static const String nameRequired = 'name_required';
  static const String priceInvalid = 'price_invalid';
  static const String minStockInvalid = 'min_stock_invalid';
  static const String concurrencyConflict = 'concurrency_conflict';
  static const String storageFailure = 'storage_failure';
  static const String unexpected = 'unexpected';
}
