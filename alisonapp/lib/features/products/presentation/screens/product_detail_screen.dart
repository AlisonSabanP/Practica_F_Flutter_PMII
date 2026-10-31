import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario/core/providers.dart';
import 'package:inventario/core/utils/formatters.dart';
import 'package:inventario/core/widgets/empty_state.dart';
import 'package:inventario/core/widgets/feedback.dart';
import 'package:inventario/features/inventory/domain/entities/movement.dart';
import 'package:inventario/features/inventory/domain/entities/movement_filter.dart';
import 'package:inventario/features/inventory/presentation/screens/movement_screen.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/presentation/screens/product_form_screen.dart';
import 'package:inventario/features/products/presentation/widgets/product_label.dart';
import 'package:inventario/features/products/presentation/widgets/product_tile.dart';

/// Detalle del producto con existencias, etiquetas y movimientos recientes.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final GlobalKey _labelKey = GlobalKey();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Product?> product = ref.watch(
      productByIdProvider(widget.productId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        actions: <Widget>[
          product.maybeWhen(
            data: (Product? value) => value == null
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Editar',
                    onPressed: () => _openEdit(value),
                    icon: const Icon(Icons.edit_outlined),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: product.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => const EmptyState(
          icon: Icons.error_outline,
          title: 'No se pudo cargar el producto',
        ),
        data: (Product? value) {
          if (value == null) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'El producto ya no está disponible',
            );
          }
          return _buildBody(value);
        },
      ),
    );
  }

  Widget _buildBody(Product product) {
    final AsyncValue<List<Movement>> movements = ref.watch(
      movementHistoryProvider(
        MovementFilter(productId: product.id, limit: 10),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _Header(product: product),
        const SizedBox(height: 20),
        _StockSummary(product: product),
        const SizedBox(height: 20),
        Text(
          'Registrar movimiento',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            for (final MovementType type in MovementType.values)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: type == MovementType.ajuste ? 0 : 10,
                  ),
                  child: OutlinedButton(
                    onPressed: !product.active
                        ? null
                        : () => _openMovement(product, type),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      padding: EdgeInsets.zero,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(iconForMovement(type), size: 18),
                        const SizedBox(height: 2),
                        Text(type.label, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (!product.active)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'El producto está desactivado. Reactívalo para registrar movimientos.',
              style: TextStyle(color: Color(0xFFB3261E)),
            ),
          ),
        const SizedBox(height: 24),
        Text(
          'Etiqueta',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: RepaintBoundary(
            key: _labelKey,
            child: ProductLabel(product: product),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _exportLabel(product),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Exportar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _shareLabel(product),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Compartir'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Movimientos recientes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        movements.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (Object error, StackTrace stack) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No se pudo cargar el historial.'),
          ),
          data: (List<Movement> items) {
            if (items.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Este producto todavía no tiene movimientos.'),
                ),
              );
            }
            return Card(
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < items.length; i++) ...<Widget>[
                    if (i > 0) const Divider(height: 1),
                    _MovementRow(movement: items[i]),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        if (product.active)
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _deactivate(product),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            icon: const Icon(Icons.block_outlined),
            label: const Text('Desactivar producto'),
          )
        else
          FilledButton.icon(
            onPressed: _busy ? null : () => _reactivate(product),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reactivar producto'),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _openEdit(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
  }

  Future<void> _openMovement(Product product, MovementType type) async {
    final bool? registered = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => MovementScreen(product: product, initialType: type),
      ),
    );
    if (registered ?? false) {
      ref.invalidate(productByIdProvider(product.id));
    }
  }

  Future<void> _deactivate(Product product) async {
    final bool confirmed = await _confirm(
      title: 'Desactivar producto',
      message:
          'El producto dejará de estar disponible para movimientos, pero su historial se conserva.',
    );
    if (!confirmed) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(deactivateProductUseCaseProvider)(product.id);
      ref.invalidate(productByIdProvider(product.id));
      if (mounted) {
        showSuccessSnackBar(context, 'Producto desactivado.');
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _reactivate(Product product) async {
    setState(() => _busy = true);
    try {
      await ref.read(reactivateProductUseCaseProvider)(product.id);
      ref.invalidate(productByIdProvider(product.id));
      if (mounted) {
        showSuccessSnackBar(context, 'Producto reactivado.');
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _exportLabel(Product product) async {
    setState(() => _busy = true);
    try {
      final Uint8List? bytes = await captureBoundary(_labelKey);
      if (bytes == null) {
        throw const FileSystemException('No se pudo renderizar la etiqueta.');
      }
      final File file = await ref.read(fileExporterProvider).writeBytes(
            fileName: 'etiqueta_${product.code}.png',
            bytes: bytes,
          );
      if (mounted) {
        showSuccessSnackBar(
          context,
          'Etiqueta guardada en ${file.parent.path}',
        );
      }
    } catch (error) {
      if (mounted) {
        showMessageSnackBar(
          context,
          'No se pudo exportar la etiqueta.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _shareLabel(Product product) async {
    setState(() => _busy = true);
    try {
      final Uint8List? bytes = await captureBoundary(_labelKey);
      if (bytes == null) {
        throw const FileSystemException('No se pudo renderizar la etiqueta.');
      }
      final File file = await ref.read(fileExporterProvider).writeBytes(
            fileName: 'etiqueta_${product.code}.png',
            bytes: bytes,
          );
      await ref
          .read(fileExporterProvider)
          .shareFile(file, text: '${product.name} · ${product.code}');
    } catch (error) {
      if (mounted) {
        showMessageSnackBar(
          context,
          'No se pudo compartir la etiqueta.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                image: product.photoPath == null
                    ? null
                    : DecorationImage(
                        image: FileImage(File(product.photoPath!)),
                        fit: BoxFit.cover,
                      ),
              ),
              child: product.photoPath == null
                  ? Icon(
                      Icons.inventory_2_outlined,
                      color: scheme.onSurfaceVariant,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.code,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                  ),
                  if (product.category != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(product.category!.name),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                  if (product.description.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(product.description),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockSummary extends StatelessWidget {
  const _StockSummary({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _Stat(
                    label: 'Existencias',
                    value: '${product.stockActual}',
                    emphasis: true,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Stock mínimo',
                    value: '${product.minStock}',
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: <Widget>[
                Expanded(
                  child: _Stat(
                    label: 'Precio compra',
                    value: Formatters.money(product.purchasePrice),
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Precio venta',
                    value: Formatters.money(product.salePrice),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: <Widget>[
                Expanded(
                  child: _Stat(
                    label: 'Valor en inventario',
                    value: Formatters.money(product.inventoryValue),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: StockBadge(product: product),
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

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: (emphasis
                  ? Theme.of(context).textTheme.headlineSmall
                  : Theme.of(context).textTheme.titleMedium)
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement});

  final Movement movement;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool positive = movement.delta >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Icon(
            iconForMovement(movement.type),
            size: 20,
            color: positive ? const Color(0xFF2E7D32) : scheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${movement.type.label} · ${movement.reason}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Formatters.dateTime(movement.dateTime)} · ${movement.responsible}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${positive ? '+' : ''}${movement.delta}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: positive ? const Color(0xFF2E7D32) : scheme.error,
                ),
              ),
              Text(
                'Quedan ${movement.resultingStock}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
