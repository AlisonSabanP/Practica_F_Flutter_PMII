import 'package:inventario/features/settings/domain/entities/local_profile.dart';
import 'package:inventario/features/settings/domain/repositories/profile_repository.dart';

/// Lee y guarda el perfil local del responsable.
class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Stream<LocalProfile> watch() => _repository.watchProfile();

  Future<LocalProfile> call() => _repository.getProfile();
}

/// Guarda el perfil local validando el nombre del responsable.
class SaveProfileUseCase {
  const SaveProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<LocalProfile> call(LocalProfile profile) async {
    final String responsible = profile.responsibleName.trim();
    final String store = profile.storeName.trim();
    final LocalProfile normalized = profile.copyWith(
      responsibleName: responsible,
      storeName: store,
    );
    await _repository.saveProfile(normalized);
    return normalized;
  }
}
