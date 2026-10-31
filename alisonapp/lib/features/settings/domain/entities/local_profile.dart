/// Perfil local del dispositivo: define el responsable por defecto.
class LocalProfile {
  const LocalProfile({
    required this.responsibleName,
    required this.storeName,
    required this.seeded,
  });

  const LocalProfile.empty()
      : responsibleName = '',
        storeName = '',
        seeded = false;

  final String responsibleName;
  final String storeName;

  /// Indica si los datos de demostración ya fueron cargados.
  final bool seeded;

  bool get isConfigured => responsibleName.trim().isNotEmpty;

  LocalProfile copyWith({
    String? responsibleName,
    String? storeName,
    bool? seeded,
  }) {
    return LocalProfile(
      responsibleName: responsibleName ?? this.responsibleName,
      storeName: storeName ?? this.storeName,
      seeded: seeded ?? this.seeded,
    );
  }
}
