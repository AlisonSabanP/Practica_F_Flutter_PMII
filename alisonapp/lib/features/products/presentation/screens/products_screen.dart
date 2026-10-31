import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario/core/providers.dart';
import 'package:inventario/core/widgets/empty_state.dart';
import 'package:inventario/features/products/domain/entities/category.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/presentation/screens/product_form_screen.dart';
import 'package:inventario/features/products/presentation/widgets/product_tile.dart';

/// Listado de productos con búsqueda y filtros.
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _search = TextEditingController();
  int? _categoryId;
  bool _onlyLowStock = false;
  bool _includeInactive = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Product>> products = ref.watch(
      _includeInactive ? allProductsProvider : productsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Mostrar inactivos',
            onPressed: () =>
                setState(() => _includeInactive = !_includeInactive),
            icon: Icon(
              _includeInactive
                  ? Icons.visibility
                  : Icons.visibility_off_outlined,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String value) {
              switch (value) {
                case 'low':
                  setState(() => _onlyLowStock = !_onlyLowStock);
                case 'clear':
                  setState(() {
                    _categoryId = null;
                    _onlyLowStock = false;
                    _search.clear();
                  });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              CheckedPopupMenuItem<String>(
                value: 'low',
                checked: _onlyLowStock,
                child: const Text('Solo stock bajo'),
              ),
              const PopupMenuItem<String>(
                value: 'clear',
                child: Text('Limpiar filtros'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProductFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Producto'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o código',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          _CategoryFilter(
            selectedId: _categoryId,
            onChanged: (int? id) => setState(() => _categoryId = id),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stack) => EmptyState(
                icon: Icons.error_outline,
                title: 'No se pudieron cargar los productos',
                action: FilledButton(
                  onPressed: () => ref.invalidate(productsProvider),
                  child: const Text('Reintentar'),
                ),
              ),
              data: (List<Product> all) {
                final List<Product> filtered = _applyFilters(all);
                if (all.isEmpty) {
                  return EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Aún no hay productos',
                    message: 'Registra tu primer producto para comenzar.',
                    action: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProductFormScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Nuevo producto'),
                    ),
                  );
                }
                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'Sin resultados',
                    message: 'Ajusta la búsqueda o los filtros aplicados.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) =>
                      ProductTile(product: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Product> _applyFilters(List<Product> products) {
    final String needle = _search.text.trim().toLowerCase();
    return products.where((Product product) {
      if (_categoryId != null && product.categoryId != _categoryId) {
        return false;
      }
      if (_onlyLowStock && !product.isLowStock) {
        return false;
      }
      if (needle.isEmpty) {
        return true;
      }
      return product.name.toLowerCase().contains(needle) ||
          product.code.toLowerCase().contains(needle);
    }).toList(growable: false);
  }
}

class _CategoryFilter extends ConsumerWidget {
  const _CategoryFilter({required this.selectedId, required this.onChanged});

  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Category>> categories = ref.watch(categoriesProvider);

    return SizedBox(
      height: 44,
      child: categories.maybeWhen(
        data: (List<Category> items) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Todas'),
                selected: selectedId == null,
                onSelected: (_) => onChanged(null),
              ),
            ),
            for (final Category category in items)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category.name),
                  selected: selectedId == category.id,
                  onSelected: (bool selected) =>
                      onChanged(selected ? category.id : null),
                ),
              ),
          ],
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}
