import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario/core/providers.dart';
import 'package:inventario/core/theme/app_theme.dart';
import 'package:inventario/core/widgets/empty_state.dart';
import 'package:inventario/features/home/presentation/screens/home_shell.dart';

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INVENTARIO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _BootstrapGate(),
    );
  }
}

/// Prepara la base de datos y los datos de demostración antes de abrir la app.
class _BootstrapGate extends ConsumerWidget {
  const _BootstrapGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<bool> bootstrap = ref.watch(bootstrapProvider);

    return bootstrap.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stack) {
        debugPrint('Bootstrap error: $error\n$stack');
        return Scaffold(
        body: EmptyState(
          icon: Icons.storage_outlined,
          title: 'No se pudo preparar el almacenamiento local',
          message: 'Cierra la aplicación y vuelve a intentarlo.',
          action: FilledButton.icon(
            onPressed: () => ref.invalidate(bootstrapProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ),
      );
      },
      data: (_) => const HomeShell(),
    );
  }
}
