import 'package:inventario/features/settings/domain/repositories/demo_data_repository.dart';

/// Carga los datos de demostración la primera vez que se abre la app.
class SeedDemoDataUseCase {
  const SeedDemoDataUseCase(this._repository);

  final DemoDataRepository _repository;

  Future<bool> call() => _repository.seedIfEmpty();
}
