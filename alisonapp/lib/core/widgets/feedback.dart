import 'package:flutter/material.dart';
import 'package:inventario/core/error/app_failure.dart';
import 'package:inventario/core/error/domain_exception.dart';

/// Muestra un mensaje de error legible para el usuario.
void showFailureSnackBar(BuildContext context, Object error) {
  final String message = switch (error) {
    DomainException(:final message) => message,
    AppFailure(:final message) => message,
    _ => 'No se pudo completar la operación.',
  };
  showMessageSnackBar(context, message, isError: true);
}

/// Muestra una confirmación breve.
void showSuccessSnackBar(BuildContext context, String message) {
  showMessageSnackBar(context, message);
}

void showMessageSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: <Widget>[
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? scheme.onErrorContainer : scheme.onPrimaryContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor:
          isError ? scheme.errorContainer : scheme.primaryContainer,
      duration: Duration(seconds: isError ? 4 : 2),
    ),
  );
}
