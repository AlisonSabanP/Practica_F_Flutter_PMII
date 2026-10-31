import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inventario/core/utils/formatters.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/presentation/screens/product_detail_screen.dart';

/// Elemento de lista reutilizable para mostrar un producto.
class ProductTile extends ConsumerWidget {
  const ProductTile({
    super.key,
    required this.product,
    this.onTap,
    this.trailing,
  });

  final Product product;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap ??
            () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProductDetailScreen(productId: product.id),
                  ),
                ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.code,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 0.6,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        StockBadge(product: product),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.money(product.salePrice),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (!product.active) ...<Widget>[
                          const SizedBox(width: 8),
                          Text(
                            'Inactivo',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Etiqueta de estado de existencias respecto al mínimo.
class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final (Color background, Color foreground, String text) = switch (
        product.stockStatus) {
      StockStatus.outOfStock => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          'Sin existencias',
        ),
      StockStatus.low => (
          const Color(0xFFFFF3E0),
          const Color(0xFF8A4B00),
          'Stock bajo',
        ),
      StockStatus.ok => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          'Disponible',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${product.stockActual} · $text',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

/// Mapea el tipo de movimiento a un icono coherente en toda la interfaz.
IconData iconForMovement(MovementType type) => switch (type) {
      MovementType.entrada => Icons.arrow_downward,
      MovementType.salida => Icons.arrow_upward,
      MovementType.ajuste => Icons.tune,
    };
