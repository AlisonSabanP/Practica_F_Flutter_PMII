import 'package:drift/drift.dart';
import 'package:inventario/core/database/app_database.dart';
import 'package:inventario/features/settings/domain/entities/local_profile.dart';
import 'package:inventario/features/settings/domain/repositories/profile_repository.dart';

/// Perfil local persistido en la tabla [Profiles] con una sola fila (id = 1).
class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(this._db);

  final AppDatabase _db;

  static const int _singletonId = 1;

  @override
  Stream<LocalProfile> watchProfile() {
    return (_db.select(_db.profiles)
          ..where((Profiles t) => t.id.equals(_singletonId)))
        .watchSingleOrNull()
        .map(_toEntity);
  }

  @override
  Future<LocalProfile> getProfile() async {
    final ProfileRow? row = await (_db.select(_db.profiles)
          ..where((Profiles t) => t.id.equals(_singletonId)))
        .getSingleOrNull();
    return _toEntity(row);
  }

  @override
  Future<void> saveProfile(LocalProfile profile) async {
    await _db.into(_db.profiles).insertOnConflictUpdate(
          ProfilesCompanion(
            id: const Value(_singletonId),
            responsibleName: Value(profile.responsibleName),
            storeName: Value(profile.storeName),
            seeded: Value(profile.seeded),
          ),
        );
  }

  @override
  Future<void> markSeeded() async {
    final LocalProfile current = await getProfile();
    await saveProfile(current.copyWith(seeded: true));
  }

  LocalProfile _toEntity(ProfileRow? row) {
    if (row == null) {
      return const LocalProfile.empty();
    }
    return LocalProfile(
      responsibleName: row.responsibleName,
      storeName: row.storeName,
      seeded: row.seeded,
    );
  }
}
