import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventario/core/providers.dart';
import 'package:inventario/core/utils/code_generator.dart';
import 'package:inventario/core/widgets/feedback.dart';
import 'package:inventario/features/products/domain/entities/category.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/domain/entities/product_draft.dart';
import 'package:inventario/features/products/domain/services/product_validator.dart';
import 'package:inventario/features/products/presentation/screens/product_detail_screen.dart';

/// Formulario de creación y edición de productos.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CodeGenerator _generator = CodeGenerator();

  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _purchasePrice;
  late final TextEditingController _salePrice;
  late final TextEditingController _minStock;
  late final TextEditingController _initialStock;

  int? _categoryId;
  String? _photoPath;
  bool _active = true;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final Product? product = widget.product;
    _code = TextEditingController(text: product?.code ?? _generator.next());
    _name = TextEditingController(text: product?.name ?? '');
    _description = TextEditingController(text: product?.description ?? '');
    _purchasePrice = TextEditingController(
      text: product == null ? '' : _formatNumber(product.purchasePrice),
    );
    _salePrice = TextEditingController(
      text: product == null ? '' : _formatNumber(product.salePrice),
    );
    _minStock = TextEditingController(text: product?.minStock.toString() ?? '0');
    _initialStock = TextEditingController();
    _categoryId = product?.categoryId;
    _photoPath = product?.photoPath;
    _active = product?.active ?? true;
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _description.dispose();
    _purchasePrice.dispose();
    _salePrice.dispose();
    _minStock.dispose();
    _initialStock.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Category>> categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _PhotoPicker(
              path: _photoPath,
              onPick: _pickPhoto,
              onClear: () => setState(() => _photoPath = null),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-_]')),
                LengthLimitingTextInputFormatter(32),
              ],
              decoration: InputDecoration(
                labelText: 'Código único',
                helperText: 'Se usa para generar el código de barras y el QR.',
                suffixIcon: IconButton(
                  tooltip: 'Generar código',
                  onPressed: () =>
                      setState(() => _code.text = _generator.next()),
                  icon: const Icon(Icons.autorenew),
                ),
              ),
              validator: ProductValidator.validateCode,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: ProductValidator.validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            categories.when(
              loading: () => const LinearProgressIndicator(),
              error: (Object error, StackTrace stack) =>
                  const Text('No se pudieron cargar las categorías.'),
              data: (List<Category> items) => DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: <DropdownMenuItem<int>>[
                  for (final Category category in items)
                    DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                ],
                onChanged: (int? value) => setState(() => _categoryId = value),
                validator: (int? value) =>
                    value == null ? 'Selecciona una categoría.' : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _purchasePrice,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Precio de compra',
                      prefixText: 'Q ',
                    ),
                    validator: ProductValidator.validatePrice,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _salePrice,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Precio de venta',
                      prefixText: 'Q ',
                    ),
                    validator: ProductValidator.validatePrice,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minStock,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(labelText: 'Stock mínimo'),
              validator: ProductValidator.validateMinStock,
            ),
            if (!_isEditing) ...<Widget>[
              const SizedBox(height: 16),
              TextFormField(
                controller: _initialStock,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Existencias iniciales (opcional)',
                  helperText:
                      'Se registran como un movimiento de entrada automático.',
                ),
                validator: ProductValidator.validateInitialStock,
              ),
            ],
            if (_isEditing) ...<Widget>[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (bool value) => setState(() => _active = value),
                title: const Text('Producto activo'),
                subtitle: const Text(
                  'Los productos inactivos no admiten movimientos.',
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isEditing ? 'Guardar cambios' : 'Crear producto'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1200,
      );
      if (file == null) {
        return;
      }
      setState(() => _photoPath = file.path);
    } on PlatformException {
      if (mounted) {
        showMessageSnackBar(
          context,
          'No se pudo acceder a la galería del dispositivo.',
          isError: true,
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_categoryId == null) {
      return;
    }

    setState(() => _saving = true);
    try {
      final ProductDraft draft = ProductDraft(
        id: widget.product?.id,
        code: _code.text.trim(),
        name: _name.text.trim(),
        description: _description.text.trim(),
        categoryId: _categoryId!,
        purchasePrice:
            ProductValidator.parseDecimal(_purchasePrice.text) ?? 0,
        salePrice: ProductValidator.parseDecimal(_salePrice.text) ?? 0,
        minStock: int.tryParse(_minStock.text.trim()) ?? 0,
        photoPath: _photoPath,
        initialStock: int.tryParse(_initialStock.text.trim()) ?? 0,
        active: _active,
        responsible: ref.read(profileProvider).valueOrNull?.responsibleName ?? '',
      );

      if (_isEditing) {
        final Product updated =
            await ref.read(updateProductUseCaseProvider)(draft);
        if (!mounted) {
          return;
        }
        showSuccessSnackBar(context, 'Producto actualizado.');
        Navigator.of(context).pop(updated);
      } else {
        final Product created =
            await ref.read(createProductUseCaseProvider)(draft);
        if (!mounted) {
          return;
        }
        showSuccessSnackBar(context, 'Producto creado.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => ProductDetailScreen(productId: created.id),
          ),
        );
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

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.path,
    required this.onPick,
    required this.onClear,
  });

  final String? path;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outlineVariant),
            image: path == null
                ? null
                : DecorationImage(
                    image: FileImage(File(path!)),
                    fit: BoxFit.cover,
                  ),
          ),
          child: path == null
              ? Icon(Icons.image_outlined, color: scheme.onSurfaceVariant)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Fotografía (opcional)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: Text(path == null ? 'Elegir' : 'Cambiar'),
                  ),
                  if (path != null)
                    TextButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Quitar'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
