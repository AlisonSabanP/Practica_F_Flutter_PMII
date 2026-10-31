import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario/core/providers.dart';
import 'package:inventario/core/widgets/feedback.dart';
import 'package:inventario/features/settings/domain/entities/local_profile.dart';

/// Configuración del perfil local: responsable por defecto y nombre de tienda.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _responsible = TextEditingController();
  final TextEditingController _store = TextEditingController();

  bool _saving = false;
  bool _loaded = false;

  @override
  void dispose() {
    _responsible.dispose();
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<LocalProfile> profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil local')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No se pudo cargar el perfil local.'),
          ),
        ),
        data: (LocalProfile data) {
          if (!_loaded) {
            _responsible.text = data.responsibleName;
            _store.text = data.storeName;
            _loaded = true;
          }
          return _buildForm(data);
        },
      ),
    );
  }

  Widget _buildForm(LocalProfile profile) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(
                      Icons.person_outline,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          profile.isConfigured
                              ? profile.responsibleName
                              : 'Sin responsable configurado',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.storeName.isEmpty
                              ? 'Tienda sin nombre'
                              : profile.storeName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _responsible,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre del responsable',
              helperText:
                  'Se usa como responsable en cada movimiento registrado.',
            ),
            validator: (String? value) => (value ?? '').trim().isEmpty
                ? 'El responsable es obligatorio.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _store,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre de la tienda o bodega (opcional)',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Guardar perfil'),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Almacenamiento local',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Los productos, categorías, movimientos y el perfil se guardan en el dispositivo. '
                    'La aplicación funciona sin conexión a internet.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(saveProfileUseCaseProvider)(
        LocalProfile(
          responsibleName: _responsible.text.trim(),
          storeName: _store.text.trim(),
          seeded: true,
        ),
      );
      if (mounted) {
        showSuccessSnackBar(context, 'Perfil guardado.');
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
