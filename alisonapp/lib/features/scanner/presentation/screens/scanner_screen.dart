import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario/core/providers.dart';
import 'package:inventario/core/widgets/empty_state.dart';
import 'package:inventario/core/widgets/feedback.dart';
import 'package:inventario/features/products/domain/entities/product.dart';
import 'package:inventario/features/products/presentation/screens/product_detail_screen.dart';
import 'package:inventario/features/products/presentation/widgets/product_tile.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Lectura de códigos de barras y QR con la cámara.
///
/// Si la cámara no está disponible o el permiso fue denegado, ofrece la
/// búsqueda manual por código o nombre.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, this.active = true});

  /// Whether this scanner is the currently selected destination.
  ///
  /// The home shell keeps its destinations mounted in an [IndexedStack], so
  /// inactive scanner instances must not acquire the camera in the background.
  final bool active;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  MobileScannerController? _controller;
  final TextEditingController _manual = TextEditingController();

  bool _torchOn = false;
  bool _handling = false;
  String? _lastCode;
  DateTime? _lastScanAt;
  MobileScannerErrorCode? _cameraError;
  bool _cameraUnavailable = false;

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  @override
  void didUpdateWidget(covariant ScannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _setCameraActive(widget.active);
    }
  }

  void _setCameraActive(bool active) {
    final MobileScannerController? controller = _controller;
    if (controller == null) {
      return;
    }

    final Future<void> operation =
        active ? controller.start() : controller.stop();
    unawaited(
      operation.catchError((Object error, StackTrace stackTrace) {
        _onCameraError(error, stackTrace);
      }),
    );
  }

  void _startCamera() {
    try {
      _controller = MobileScannerController(
        autoStart: widget.active,
        detectionSpeed: DetectionSpeed.noDuplicates,
        formats: const <BarcodeFormat>[
          BarcodeFormat.code128,
          BarcodeFormat.qrCode,
        ],
      );
    } catch (_) {
      setState(() => _cameraUnavailable = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _manual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear'),
        actions: <Widget>[
          if (!_cameraUnavailable && _cameraError == null)
            IconButton(
              tooltip: 'Linterna',
              onPressed: () async {
                await _controller?.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
              icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _CameraArea(
            controller: _controller,
            error: _cameraError,
            unavailable: _cameraUnavailable,
            onDetect: _onDetect,
            onError: _onCameraError,
            onRetry: _retryCamera,
          ),
          const Divider(height: 1),
          _ManualSearch(
            controller: _manual,
            onSubmit: _onManualSubmit,
          ),
        ],
      ),
    );
  }

  void _onCameraError(Object error, StackTrace stackTrace) {
    if (!mounted) {
      return;
    }
    final MobileScannerErrorCode code = error is MobileScannerException
        ? error.errorCode
        : MobileScannerErrorCode.genericError;
    setState(() => _cameraError = code);
  }

  void _retryCamera() {
    setState(() {
      _cameraError = null;
      _cameraUnavailable = false;
    });
    _controller?.dispose();
    _startCamera();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) {
      return;
    }
    final String? raw = capture.barcodes
        .map((Barcode barcode) => barcode.rawValue)
        .firstWhere((String? value) => value != null && value.isNotEmpty,
            orElse: () => null);
    if (raw == null) {
      return;
    }

    // Evita procesar el mismo código repetidamente mientras el usuario decide.
    final DateTime now = DateTime.now();
    if (_lastCode == raw &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastCode = raw;
    _lastScanAt = now;

    await _resolveCode(raw);
  }

  Future<void> _onManualSubmit(String value) async {
    final String code = value.trim();
    if (code.isEmpty) {
      showMessageSnackBar(
        context,
        'Ingresa un código para buscar.',
        isError: true,
      );
      return;
    }
    await _resolveCode(code);
  }

  Future<void> _resolveCode(String code) async {
    _handling = true;
    try {
      final Product? product =
          await ref.read(findProductByCodeUseCaseProvider).call(code);

      if (!mounted) {
        return;
      }

      if (product == null) {
        showMessageSnackBar(
          context,
          'Código no registrado: $code',
          isError: true,
        );
        return;
      }

      await _showProductSheet(product);
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    } finally {
      _handling = false;
    }
  }

  Future<void> _showProductSheet(Product product) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Producto encontrado',
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            ProductTile(
              product: product,
              onTap: () {
                Navigator.of(sheetContext).pop();
                _openDetail(product);
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _openDetail(product);
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ver detalle y registrar movimiento'),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(productId: product.id),
      ),
    );
  }
}

class _CameraArea extends StatelessWidget {
  const _CameraArea({
    required this.controller,
    required this.error,
    required this.unavailable,
    required this.onDetect,
    required this.onError,
    required this.onRetry,
  });

  final MobileScannerController? controller;
  final MobileScannerErrorCode? error;
  final bool unavailable;
  final ValueChanged<BarcodeCapture> onDetect;
  final void Function(Object error, StackTrace stackTrace) onError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (unavailable || error == MobileScannerErrorCode.unsupported) {
      return SizedBox(
        height: 300,
        child: EmptyState(
          icon: Icons.no_photography_outlined,
          title: 'Cámara no disponible',
          message:
              'Este dispositivo no permite escanear. Usa la búsqueda manual por código o nombre.',
          action: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ),
      );
    }

    if (error == MobileScannerErrorCode.permissionDenied) {
      return SizedBox(
        height: 300,
        child: EmptyState(
          icon: Icons.lock_outline,
          title: 'Permiso de cámara denegado',
          message:
              'Habilita el permiso de cámara en los ajustes del sistema y vuelve a intentarlo.',
          action: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ),
      );
    }

    if (error != null) {
      return SizedBox(
        height: 300,
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'No se pudo iniciar la cámara',
          message: 'Vuelve a intentarlo o usa la búsqueda manual.',
          action: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          MobileScanner(
            controller: controller,
            onDetect: onDetect,
            onDetectError: onError,
            errorBuilder: (BuildContext context,
                MobileScannerException exception, Widget? child) {
              onError(exception, StackTrace.current);
              return const SizedBox.shrink();
            },
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 220,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Apunta la cámara al código de barras o al QR',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualSearch extends ConsumerStatefulWidget {
  const _ManualSearch({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  @override
  ConsumerState<_ManualSearch> createState() => _ManualSearchState();
}

class _ManualSearchState extends ConsumerState<_ManualSearch> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Product>> products = ref.watch(allProductsProvider);

    return Expanded(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: widget.controller,
              onChanged: (String value) => setState(() => _query = value),
              onSubmitted: widget.onSubmit,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Búsqueda manual',
                hintText: 'Código o nombre del producto',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => widget.onSubmit(widget.controller.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stack) => const EmptyState(
                icon: Icons.error_outline,
                title: 'No se pudieron cargar los productos',
              ),
              data: (List<Product> all) {
                final String needle = _query.trim().toLowerCase();
                if (needle.isEmpty) {
                  return const EmptyState(
                    icon: Icons.qr_code_scanner,
                    title: 'Sin búsqueda activa',
                    message:
                        'Escribe un código o nombre para localizar el producto.',
                  );
                }
                final List<Product> matches = all
                    .where((Product product) =>
                        product.code.toLowerCase().contains(needle) ||
                        product.name.toLowerCase().contains(needle))
                    .toList(growable: false);
                if (matches.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'Código no registrado',
                    message: 'No hay productos que coincidan con la búsqueda.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: matches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) =>
                      ProductTile(product: matches[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
