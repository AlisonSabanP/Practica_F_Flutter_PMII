/// Resultado calculado de aplicar un movimiento sobre un stock conocido.
class StockChange {
  const StockChange({required this.previousStock, required this.resultingStock});

  final int previousStock;
  final int resultingStock;

  int get delta => resultingStock - previousStock;
}
