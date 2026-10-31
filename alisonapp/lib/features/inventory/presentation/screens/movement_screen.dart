import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario/core/providers.dart';
import 'package:inventario/core/widgets/feedback.dart';
import 'package:inventario/features/inventory/domain/entities/movement_request.dart';
import 'package:inventario/features/inventory/domain/entities/movement_type.dart';
import 'package:inventario/features/inventory/domain/services/movement_validator.dart';
import 'package:inventario/features/products/domain/entities/product.dart';

/// Registro de entrada, salida y ajuste de existencias.
class MovementScreen extends ConsumerStatefulWidget {
  const MovementScreen({
    super.key,
    required this.product,
    this.initialType = MovementType.entrada,
  });

  final Product product;
  final MovementType initialType;

  @override
  ConsumerState<MovementScreen> createState() => _MovementScreenState();
}

class _MovementScreenState extends ConsumerState<MovementScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _justification = TextEditingController();

  late MovementType _type;
  String? _reason;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _reason = MovementReasons.forType(_type).first;
  }

  @override
  void dispose() {
    _quantity.dispose();
    _justification.dispose();
    super.dispose();
  }

  bool get _isAdjustment => _type == MovementType.ajuste;

  @override
  Widget build(BuildContext context) {
    final int stock = widget.product.stockActual;

    return Scaffold(
      appBar: AppBar(title: Text('${_type.label} de existencias')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.product.code),
                    const SizedBox(height: 12),
                    Text(
                      'Existencias actuales: $stock unidades',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SegmentedButton<MovementType>(
              segments: <ButtonSegment<MovementType>>[
                for (final MovementType type in MovementType.values)
                  ButtonSegment<MovementType>(
                    value: type,
                    label: Text(type.label),
                    icon: Icon(
                      switch (type) {
                        MovementType.entrada => Icons.arrow_downward,
                        MovementType.salida => Icons.arrow_upward,
                        MovementType.ajuste => Icons.tune,
                      },
                    ),
                  ),
              ],
              selected: <MovementType>{_type},
              onSelectionChanged: (Set<MovementType> selection) {
                setState(() {
                  _type = selection.first;
                  _reason = MovementReasons.forType(_type).first;
                  _quantity.clear();
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: _isAdjustment
                    ? 'Cantidad contada'
                    : 'Cantidad a ${_type == MovementType.entrada ? 'ingresar' : 'retirar'}',
                helperText: _isAdjustment
                    ? 'Las existencias pasarán a este valor.'
                    : null,
              ),
              validator: (String? value) {
                final int? parsed = int.tryParse((value ?? '').trim());
                if (parsed == null) {
                  return 'Ingresa una cantidad válida.';
                }
                if (!_isAdjustment && parsed <= 0) {
                  return 'La cantidad debe ser mayor que cero.';
                }
                if (_isAdjustment && parsed < 0) {
                  return 'La cantidad no puede ser negativa.';
                }
                if (_type == MovementType.salida && parsed > stock) {
                  return 'Stock insuficiente: solo hay $stock unidades.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _reason,
              decoration: const InputDecoration(labelText: 'Motivo'),
              items: <DropdownMenuItem<String>>[
                for (final String reason in MovementReasons.forType(_type))
                  DropdownMenuItem<String>(value: reason, child: Text(reason)),
              ],
              onChanged: (String? value) => setState(() => _reason = value),
              validator: (String? value) =>
                  (value ?? '').isEmpty ? 'Selecciona un motivo.' : null,
            ),
            if (_isAdjustment) ...<Widget>[
              const SizedBox(height: 16),
              TextFormField(
                controller: _justification,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Justificación del ajuste',
                  alignLabelWithHint: true,
                  helperText: 'Obligatoria para ajustes por conteo físico.',
                ),
                validator: (String? value) => (value ?? '').trim().isEmpty
                    ? 'El ajuste requiere una justificación.'
                    : null,
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
                  : const Icon(Icons.check),
              label: Text('Registrar ${_type.label.toLowerCase()}'),
            ),
            const SizedBox(height: 12),
            Text(
              'Los movimientos confirmados no se editan ni se eliminan. '
              'Si hubo un error, registra un movimiento de ajuste.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final String responsible =
        ref.read(profileProvider).valueOrNull?.responsibleName ?? '';
    if (responsible.trim().isEmpty) {
      showMessageSnackBar(
        context,
        'Configura el responsable en la sección Perfil antes de registrar movimientos.',
        isError: true,
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(registerMovementUseCaseProvider)(
        MovementRequest(
          productId: widget.product.id,
          type: _type,
          quantity: int.tryParse(_quantity.text.trim()) ?? 0,
          reason: _reason ?? MovementReasons.forType(_type).first,
          responsible: responsible,
          justification: _isAdjustment ? _justification.text : null,
        ),
      );
      if (!mounted) {
        return;
      }
      showSuccessSnackBar(context, '${_type.label} registrada.');
      Navigator.of(context).pop(true);
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
