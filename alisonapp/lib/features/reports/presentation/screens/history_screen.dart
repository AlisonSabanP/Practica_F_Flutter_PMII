import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario/core/providers.dart';
import 'package:inventario/core/utils/formatters.dart';
import 'package:inventario/core/widgets/empty_state.dart';
import 'package:inventario/core/widgets/feedback.dart';
import 'package:inventario/core/widgets/metric_card.dart';
import 'package:inventario/features/inventory/domain/entities/movement.dart';
import 'package:inventario/features/inventory/domain/entities/movement_filter.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/presentation/widgets/product_tile.dart';
import 'package:inventario/features/reports/domain/entities/inventory_report.dart';

/// Historial de movimientos con filtros y exportación del inventario a CSV.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final MovementFilter filter = ref.watch(movementFilterProvider);
    final AsyncValue<List<Movement>> history =
        ref.watch(movementHistoryProvider(filter));
    final AsyncValue<InventoryReport> report =
        ref.watch(inventoryReportProvider);
    final AsyncValue<List<Product>> lowStock = ref.watch(lowStockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial y reportes'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Exportar inventario a CSV',
            onPressed: _exporting ? null : _export,
            icon: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.file_download_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          report.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stack) => const SizedBox.shrink(),
            data: (InventoryReport data) => Column(
              children: <Widget>[
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: <Widget>[
                    MetricCard(
                      label: 'Productos',
                      value: '${data.totalProducts}',
                      icon: Icons.inventory_2_outlined,
                    ),
                    MetricCard(
                      label: 'Unidades',
                      value: Formatters.integer(data.totalUnits),
                      icon: Icons.straighten,
                    ),
                    MetricCard(
                      label: 'Valor (precio compra)',
                      value: Formatters.money(data.totalValue),
                      icon: Icons.attach_money,
                      tone: const Color(0xFF2E7D32),
                    ),
                    MetricCard(
                      label: 'Alertas de stock',
                      value: '${data.lowStockCount + data.outOfStockCount}',
                      icon: Icons.warning_amber_outlined,
                      tone: const Color(0xFFE65100),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _FilterBar(
            filter: filter,
            onChanged: (MovementFilter updated) => _applyFilter(updated),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Movimientos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                '${history.valueOrNull?.length ?? 0} registros',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          history.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stack) => const EmptyState(
              icon: Icons.error_outline,
              title: 'No se pudo cargar el historial',
            ),
            data: (List<Movement> items) {
              if (items.isEmpty) {
                return const EmptyState(
                  icon: Icons.history,
                  title: 'Sin movimientos',
                  message: 'Ajusta los filtros o registra un movimiento.',
                );
              }
              return Column(
                children: <Widget>[
                  for (final Movement movement in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MovementCard(movement: movement),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Alertas de stock',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          lowStock.when(
            loading: () => const SizedBox.shrink(),
            error: (Object error, StackTrace stack) => const SizedBox.shrink(),
            data: (List<Product> items) {
              if (items.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Sin productos por debajo del mínimo.'),
                  ),
                );
              }
              return Column(
                children: <Widget>[
                  for (final Product product in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ProductTile(product: product),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _applyFilter(MovementFilter updated) {
    final MovementFilterNotifier notifier =
        ref.read(movementFilterProvider.notifier);
    notifier.setProduct(updated.productId);
    notifier.setType(updated.type);
    notifier.setDateRange(updated.from, updated.to);
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final File file = await ref.read(exportInventoryCsvUseCaseProvider)();
      if (!mounted) {
        return;
      }
      showSuccessSnackBar(context, 'CSV guardado en ${file.parent.path}');
      await ref
          .read(fileExporterProvider)
          .shareFile(file, text: 'Inventario exportado');
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter, required this.onChanged});

  final MovementFilter filter;
  final ValueChanged<MovementFilter> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Product>> products = ref.watch(allProductsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField<int?>(
              value: filter.productId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Producto',
                isDense: true,
              ),
              items: <DropdownMenuItem<int?>>[
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todos los productos'),
                ),
                for (final Product product
                    in products.valueOrNull ?? const <Product>[])
                  DropdownMenuItem<int?>(
                    value: product.id,
                    child: Text(
                      product.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (int? value) =>
                  onChanged(filter.copyWith(productId: value)),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<MovementType?>(
              value: filter.type,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                isDense: true,
              ),
              items: <DropdownMenuItem<MovementType?>>[
                const DropdownMenuItem<MovementType?>(
                  value: null,
                  child: Text('Todos los tipos'),
                ),
                for (final MovementType type in MovementType.values)
                  DropdownMenuItem<MovementType?>(
                    value: type,
                    child: Text(type.label),
                  ),
              ],
              onChanged: (MovementType? value) =>
                  onChanged(filter.copyWith(type: value)),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final DateTimeRange? range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (range != null) {
                        onChanged(
                          filter.copyWith(
                            from: range.start,
                            to: DateTime(
                              range.end.year,
                              range.end.month,
                              range.end.day,
                              23,
                              59,
                              59,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.date_range_outlined, size: 18),
                    label: Text(
                      filter.from == null || filter.to == null
                          ? 'Rango de fechas'
                          : '${Formatters.date(filter.from!)} - ${Formatters.date(filter.to!)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Limpiar filtros',
                  onPressed: () => ref.read(movementFilterProvider.notifier).clear(),
                  icon: const Icon(Icons.filter_alt_off_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementCard extends StatelessWidget {
  const _MovementCard({required this.movement});

  final Movement movement;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool positive = movement.delta >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: positive
                    ? const Color(0xFFE8F5E9)
                    : scheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                iconForMovement(movement.type),
                size: 18,
                color: positive ? const Color(0xFF2E7D32) : scheme.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    movement.productName ?? 'Producto #${movement.productId}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${movement.type.label} · ${movement.reason}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  if (movement.type == MovementType.ajuste)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Justificación registrada',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.dateTime(movement.dateTime)} · ${movement.responsible}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${positive ? '+' : ''}${movement.delta}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: positive ? const Color(0xFF2E7D32) : scheme.error,
                  ),
                ),
                Text(
                  '${movement.previousStock} → ${movement.resultingStock}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
