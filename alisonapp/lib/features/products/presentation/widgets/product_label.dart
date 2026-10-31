import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:inventario/features/products/domain/entities/product.dart';

/// Etiqueta imprimible con nombre, código, código de barras Code 128 y QR.
///
/// El QR contiene únicamente el código único del producto: las cantidades y
/// existencias cambian con cada movimiento y no deben codificarse.
class ProductLabel extends StatelessWidget {
  const ProductLabel({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            product.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          if (product.category != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              product.category!.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 16),
          BarcodeWidget(
            barcode: Barcode.code128(),
            data: product.code,
            height: 90,
            drawText: true,
            style: const TextStyle(
              fontSize: 14,
              letterSpacing: 2,
              color: Colors.black,
            ),
            color: Colors.black,
          ),
          const SizedBox(height: 20),
          Center(
            child: BarcodeWidget(
              barcode: Barcode.qrCode(
                errorCorrectLevel: BarcodeQRCorrectionLevel.medium,
              ),
              data: product.code,
              width: 150,
              height: 150,
              drawText: false,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.code,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              letterSpacing: 1.5,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// Convierte la etiqueta en PNG para exportarla o compartirla.
Future<Uint8List?> captureBoundary(GlobalKey key, {double pixelRatio = 3}) async {
  final RenderObject? object = key.currentContext?.findRenderObject();
  if (object is! RenderRepaintBoundary) {
    return null;
  }
  final ui.Image image = await object.toImage(pixelRatio: pixelRatio);
  final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data?.buffer.asUint8List();
}
