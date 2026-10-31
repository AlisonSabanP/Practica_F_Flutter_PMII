import 'package:inventario/features/settings/domain/entities/local_profile.dart';

/// Contrato de almacenamiento del perfil local.
abstract class ProfileRepository {
  Stream<LocalProfile> watchProfile();

  Future<LocalProfile> getProfile();

  Future<void> saveProfile(LocalProfile profile);

  Future<void> markSeeded();
}
