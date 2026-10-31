import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Directorio de trabajo de la aplicación.
///
/// Usa el directorio de documentos de la plataforma y recurre a la carpeta
/// temporal cuando esta no lo expone (por ejemplo, en escritorio Linux).
Future<Directory> resolveAppDirectory() async {
  try {
    return await getApplicationDocumentsDirectory();
  } on MissingPlatformDirectoryException {
    return Directory.systemTemp;
  }
}
