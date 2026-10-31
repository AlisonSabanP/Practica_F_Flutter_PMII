# 07. Validaciones, manejo de errores y consistencia de los movimientos

## 1. Capas de validación

### A. Validación en la presentación (UI inmediata)

Los formularios usan `TextFormField` con validadores que devuelven un mensaje de string o `null`:

| Pantalla | Campo | Validación |
|---|---|---|
| ProductFormScreen | Código | `ProductValidator.validateCode` (requerido, formato alfanumérico 3-32, guion/bajo) |
| ProductFormScreen | Nombre | `ProductValidator.validateName` (no vacío) |
| ProductFormScreen | Precio compra / venta | `ProductValidator.validatePrice` (numérico, ≥ 0; admite coma o punto) |
| ProductFormScreen | Stock mínimo | `ProductValidator.validateMinStock` (entero ≥ 0) |
| ProductFormScreen | Existencias iniciales | `ProductValidator.validateInitialStock` (opcional, entero ≥ 0) |
| ProductFormScreen | Categoría | no null ("Selecciona una categoría") |
| MovementScreen | Cantidad | entero; > 0 para entrada/salida; ≥ 0 para ajuste; ≤ stock para salida |
| MovementScreen | Motivo | no vacío |
| MovementScreen | Justificación (ajuste) | no vacía |
| ProfileScreen | Responsable | no vacío |

La UI no permite enviar el formulario mientras haya errores de validación (`_formKey.currentState?.validate()`).

### B. Validación en el dominio (reglas de negocio, obligatoria)

La capa de dominio valida **siempre**, independientemente de la UI, mediante servicios puros y casos de uso:

| Servicio | Método | Reglas |
|---|---|---|
| `ProductValidator` | `assertValid(draft)` | código válido, nombre no vacío, precios ≥ 0, minStock ≥ 0, initialStock ≥ 0; lanza `DomainException` |
| `MovementValidator` | `validate(...)` | cantidad ≥ 0, >0 para entrada/salida, motivo no vacío, responsable no vacío, justificación en ajuste |
| `StockCalculator` | `apply(...)` | entrada > 0; salida > 0 y ≤ stock (sino `insufficient_stock`); ajuste exige justificación; qty ≤ 1 000 000; no negativas |
| `RegisterMovementUseCase` | `call(request)` | responsable no vacío, salida qty > 0, delega al repositorio |
| `CreateProductUseCase` | `call(draft)` | valida draft, verifica código no duplicado (`codeDuplicated`) |
| `UpdateProductUseCase` | `call(draft)` | valida draft, verifica código no duplicado excluyendo propio id |
| `DriftMovementRepository` | `registerMovement` | producto debe existir (`productNotFound`) y estar activo (`productInactive`) |

Todas las reglas de dominio lanzan `DomainException` con un código de `ErrorCodes` y un mensaje legible.

## 2. Códigos de error (`core/error/error_codes.dart`)

| Código | Significado | Mensaje típico al usuario |
|---|---|---|
| `quantity_not_positive` | Cantidad inválida, cero o negativa, o excede el máximo | "La cantidad no puede ser negativa." / "debe ser mayor que cero." |
| `insufficient_stock` | Salida superior al stock disponible | "Stock insuficiente: solo hay X unidades disponibles." |
| `reason_required` | Motivo o responsable vacío | "El motivo es obligatorio." / "El responsable es obligatorio." |
| `justification_required` | Ajuste sin justificación | "El ajuste requiere una justificación." |
| `code_duplicated` | Código de producto ya existe | "Ya existe un producto con el código X." |
| `code_required` | Código vacío o inválido | "El código del producto no es válido." / "El código no puede estar vacío." |
| `product_not_found` | Producto inexistente | "El producto no existe." / "El producto ya no existe." |
| `product_inactive` | Producto desactivado | "El producto está desactivado y no admite movimientos." |
| `product_has_movements` | Producto con movimientos (reserva de borrado físico) | — |
| `name_required` | Nombre vacío | "El nombre del producto es obligatorio." |
| `price_invalid` | Precio negativo o inválido | "Los precios no pueden ser negativos." |
| `min_stock_invalid` | Stock mínimo negativo | "El stock mínimo no puede ser negativo." |
| `concurrency_conflict` | Conflicto de concurrencia | — |
| `storage_failure` | Fallo de almacenamiento | — |
| `unexpected` | Error inesperado | "Ocurrió un error inesperado." |

## 3. Conversión de errores a la UI

El dominio lanza `DomainException`; los casos de uso y repositorios lo propagan. La capa de presentación lo convierte a `AppFailure` y muestra un `SnackBar`:

```dart
// feedback.dart
void showFailureSnackBar(BuildContext context, Object error) {
  final String message = switch (error) {
    DomainException(:final message) => message,
    AppFailure(:final message) => message,
    _ => 'No se pudo completar la operación.',
  };
  showMessageSnackBar(context, message, isError: true);
}
```

Los `SnackBar` de error usan el color `errorContainer` del tema y duran 4 segundos; los de éxito usan `primaryContainer` y duran 2 segundos.

## 4. Consistencia y atomicidad de los movimientos

### Atomicidad (transaccionalidad)

Cada registro de movimiento y la actualización correspondiente del stock se ejecutan dentro de **una sola transacción de Drift** (`_db.transaction`):

- `DriftMovementRepository.registerMovement`: inserta en `Movements` y actualiza `Products.stockActual` en la misma transacción. Si cualquiera falla, se revierte todo.
- `DriftProductRepository.createProduct`: inserta el producto y, si hay `initialStock > 0`, registra la entrada inicial y actualiza el stock en la misma transacción.

### Inmutabilidad de movimientos

Un movimiento confirmado **nunca se edita ni se elimina**. Los errores de registro se corrigen con un nuevo movimiento (por ejemplo, un ajuste con justificación). El historial queda completo y auditables.

### Borrado lógico de productos

Los productos nunca se eliminan físicamente de la base de datos:
- Si un producto tiene movimientos asociados, se **desactiva** (`active = false`) y deja de aparecer en el catálogo activo, pero su historial de movimientos se conserva.
- Un producto desactivado no admite nuevos movimientos (`product_inactive`).
- Puede reactivarse posteriormente.

### Consistencia de stock

- `stockActual` es un valor derivado: solo cambia mediante movimientos confirmados. Editar un producto **no** toca el stock.
- Las existencias iniciales al crear un producto se registran como un movimiento de entrada ("Existencias iniciales"), no como escritura directa de stock.

## 5. Ejemplos de mensajes de error al usuario y resolución

| Situación | Mensaje mostrado | Cómo resolverlo |
|---|---|---|
| Código vacío o con símbolos no permitidos | "El código del producto no es válido." / "Usa de 3 a 32 caracteres alfanuméricos, guion o guion bajo." | Ingresar un código de 3 a 32 caracteres usando letras, números, guion o guion bajo. |
| Código duplicado | "Ya existe un producto con el código X." | Usar un código distinto o editar el producto existente. |
| Nombre vacío | "El nombre del producto es obligatorio." | Ingresar un nombre. |
| Precio negativo o no numérico | "Ingresa un número válido." / "Los precios no pueden ser negativos." | Ingresar un precio válido (puede usar coma o punto decimal). |
| Salida superior al stock | "Stock insuficiente: solo hay X unidades disponibles." | Reducir la cantidad o registrar primero una entrada. |
| Ajuste sin justificación | "El ajuste requiere una justificación." | Escribir una justificación (ej. "Conteo físico del cierre de mes"). |
| Motivo o responsable vacío | "El motivo es obligatorio." / "El responsable es obligatorio." | Seleccionar un motivo y configurar el responsable en Perfil. |
| Producto desactivado | "El producto está desactivado y no admite movimientos." | Reactivar el producto desde su detalle. |
| Cámara sin permiso | "Permiso de cámara denegado." | Habilitar el permiso de cámara en Ajustes del sistema y reintentar. |
| Cámara no disponible | "Cámara no disponible." | Usar la búsqueda manual por código o nombre. |
| Fallo al guardar/exportar | "Ocurrió un error inesperado." | Verificar almacenamiento disponible y reintentar. |

## 6. Pruebas de consistencia

Las reglas anteriores están cubiertas por pruebas unitarias en `test/domain/` (`stock_calculator_test.dart`, `movement_validator_test.dart`, `product_validator_test.dart`, `inventory_flow_test.dart`). Véase `docs/08_pruebas.md` para la evidencia detallada.
