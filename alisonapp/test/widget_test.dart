import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app.dart';
import 'package:inventario/core/theme/app_theme.dart';
import 'package:inventario/core/widgets/empty_state.dart';

void main() {
  testWidgets('la app construye el MaterialApp con el título INVENTARIO',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: InventarioApp()));

    final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'INVENTARIO');
    expect(app.theme?.useMaterial3, isTrue);
  });

  testWidgets('EmptyState muestra título, mensaje y acción',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'Sin productos',
            message: 'Agrega tu primer producto.',
            action: FilledButton(
              onPressed: () {},
              child: const Text('Agregar'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sin productos'), findsOneWidget);
    expect(find.text('Agrega tu primer producto.'), findsOneWidget);
    expect(find.text('Agregar'), findsOneWidget);
  });
}
