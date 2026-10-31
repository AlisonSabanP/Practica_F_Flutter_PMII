import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario/core/providers.dart';
import 'package:inventario/core/utils/formatters.dart';
import 'package:inventario/core/widgets/empty_state.dart';
import 'package:inventario/core/widgets/metric_card.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/presentation/screens/product_detail_screen.dart';
import 'package:inventario/features/products/presentation/screens/product_form_screen.dart';
import 'package:inventario/features/products/presentation/widgets/product_tile.dart';
import 'package:inventario/features/reports/domain/entities/inventory_report.dart';
import 'package:inventario/features/reports/presentation/screens/history_screen.dart';
import 'package:inventario/features/scanner/presentation/screens/scanner_screen.dart';

/// Pantalla de inicio con resumen, alertas de stock y accesos rápidos.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<InventoryReport> report =
        ref.watch(inventoryReportProvider);
    final AsyncValue<List<Product>> lowStock = ref.watch(lowStockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('INVENTARIO'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () {
              ref.invalidate(inventoryReportProvider);
              ref.invalidate(lowStockProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(inventoryReportProvider);
          await ref.read(allProductsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _ReportSummary(report: report),
            const SizedBox(height: 24),
            Text(
              'Accesos rápidos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            const _QuickActions(),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Alertas de stock',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (lowStock.valueOrNull != null &&
                    lowStock.valueOrNull!.isNotEmpty)
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const HistoryScreen(),
                      ),
                    ),
                    child: const Text('Ver historial'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            lowStock.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object error, StackTrace stack) => const EmptyState(
                icon: Icons.error_outline,
                title: 'No se pudieron cargar las alertas',
              ),
              data: (List<Product> products) {
                if (products.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.verified_outlined),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Todas las existencias están por encima del mínimo.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: <Widget>[
                    for (final Product product in products)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ProductTile(
                          product: product,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ProductDetailScreen(
                                productId: product.id,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSummary extends StatelessWidget {
  const _ReportSummary({required this.report});

  final AsyncValue<InventoryReport> report;

  @override
  Widget build(BuildContext context) {
    return report.when(
      loading: () => const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stack) => const EmptyState(
        icon: Icons.error_outline,
        title: 'No se pudo calcular el resumen',
      ),
      data: (InventoryReport data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: <Widget>[
              MetricCard(
                label: 'Productos activos',
                value: '${data.activeProducts}',
                icon: Icons.inventory_2_outlined,
              ),
              MetricCard(
                label: 'Unidades en stock',
                value: Formatters.integer(data.totalUnits),
                icon: Icons.straighten,
              ),
              MetricCard(
                label: 'Valor del inventario',
                value: Formatters.money(data.totalValue),
                icon: Icons.attach_money,
                tone: const Color(0xFF2E7D32),
              ),
              MetricCard(
                label: 'Alertas de stock',
                value: '${data.lowStockCount + data.outOfStockCount}',
                icon: Icons.warning_amber_outlined,
                tone: data.lowStockCount + data.outOfStockCount > 0
                    ? const Color(0xFFE65100)
                    : const Color(0xFF2E7D32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_box_outlined,
            label: 'Nuevo producto',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProductFormScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.qr_code_scanner,
            label: 'Escanear código',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ScannerScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: <Widget>[
              Icon(icon, color: scheme.primary, size: 28),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
