import 'dart:math';

/// Genera códigos únicos legibles para productos, aptos para Code 128.
class CodeGenerator {
  CodeGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const String _alphabet = '0123456789';

  /// Código con prefijo alfabético y 10 dígitos, sin caracteres ambiguos.
  String next() {
    final StringBuffer buffer = StringBuffer('P');
    for (int i = 0; i < 10; i++) {
      buffer.write(_alphabet[_random.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }
}
