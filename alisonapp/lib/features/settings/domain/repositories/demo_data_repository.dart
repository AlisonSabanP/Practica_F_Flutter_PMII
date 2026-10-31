/// Contrato para cargar datos de demostración en el almacenamiento local.
abstract class DemoDataRepository {
  /// Crea categorías, productos y movimientos iniciales coherentes.
  ///
  /// Es idempotente: si los datos ya existen no vuelve a cargarlos.
  Future<bool> seedIfEmpty();
}
