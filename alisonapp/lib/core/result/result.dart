import 'package:inventario/core/error/app_failure.dart';

/// Resultado de una operación de dominio o de datos.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  AppFailure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final failure) => failure,
      };

  T get requireValue => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => throw StateError('El resultado contiene un fallo.'),
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(AppFailure failure) onFailure,
  }) =>
      switch (this) {
        Success<T>(:final value) => success(value),
        Failure<T>(:final failure) => onFailure(failure),
      };

  /// Acceso seguro al valor exitoso, o [fallback] si hubo fallo.
  T getOrElse(T Function() fallback) => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => fallback(),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final AppFailure failure;
}
