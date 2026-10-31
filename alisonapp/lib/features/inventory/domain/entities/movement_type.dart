/// Tipo de movimiento de inventario.
enum MovementType {
  entrada('entrada'),
  salida('salida'),
  ajuste('ajuste');

  const MovementType(this.code);

  final String code;

  static MovementType fromCode(String value) => MovementType.values.firstWhere(
        (MovementType type) => type.code == value,
        orElse: () => MovementType.entrada,
      );

  String get label => switch (this) {
        MovementType.entrada => 'Entrada',
        MovementType.salida => 'Salida',
        MovementType.ajuste => 'Ajuste',
      };

  bool get increasesStock => this == MovementType.entrada;

  bool get decreasesStock => this == MovementType.salida;
}
