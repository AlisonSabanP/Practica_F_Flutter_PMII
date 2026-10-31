import 'dart:io';

import 'package:inventario/core/utils/app_directories.dart';
import 'package:share_plus/share_plus.dart';

/// Escribe archivos generados en el almacenamiento de la app y los comparte.
///
/// El almacenamiento interno de la app no requiere permisos en Android.
class FileExporter {
  const FileExporter();

  Future<Directory> _exportsDirectory() async {
    final Directory directory = await resolveAppDirectory();
    final Directory exports = Directory('${directory.path}/exportaciones');
    if (!await exports.exists()) {
      await exports.create(recursive: true);
    }
    return exports;
  }

  Future<File> writeTextFile({
    required String fileName,
    required String contents,
  }) async {
    final Directory exports = await _exportsDirectory();
    final File file = File('${exports.path}/$fileName');
    await file.writeAsString(contents, flush: true);
    return file;
  }

  Future<File> writeBytes({
    required String fileName,
    required List<int> bytes,
  }) async {
    final Directory exports = await _exportsDirectory();
    final File file = File('${exports.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Comparte el archivo con las apps disponibles.
  ///
  /// Plataformas sin hoja de compartir no deben romper la exportación: el
  /// archivo ya quedó guardado y el usuario puede recuperarlo de su carpeta.
  Future<void> shareFile(File file, {String? text}) async {
    try {
      await Share.shareXFiles(<XFile>[XFile(file.path)], text: text);
    } on Object {
      // Sin hoja de compartir disponible en esta plataforma.
    }
  }
}
