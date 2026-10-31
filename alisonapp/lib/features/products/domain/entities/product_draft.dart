/// Datos necesarios para crear o editar un producto desde la interfaz.
class ProductDraft {
  const ProductDraft({
    this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.purchasePrice,
    required this.salePrice,
    required this.minStock,
    this.photoPath,
    this.initialStock = 0,
    this.active = true,
    this.responsible = '',
  });

  final int? id;
  final String code;
  final String name;
  final String description;
  final int categoryId;
  final double purchasePrice;
  final double salePrice;
  final int minStock;
  final String? photoPath;

  /// Existencias iniciales. Solo se aplica al crear el producto y se registra
  /// como un movimiento de entrada.
  final int initialStock;
  final bool active;

  /// Responsable asignado al movimiento de existencias iniciales.
  final String responsible;

  bool get isEditing => id != null;
}
