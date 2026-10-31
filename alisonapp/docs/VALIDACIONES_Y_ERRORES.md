# Validaciones y manejo de errores

## Validaciones de formularios

Las validaciones de producto viven en
`lib/features/products/domain/services/product_validator.dart` y se reutilizan
tanto en el dominio como en los formularios.

| Campo | Regla | Mensaje |
| --- | --- | --- |
| Código | Obligatorio | `El código es obligatorio.` |
| Código | 3 a 32 caracteres alfanuméricos, guion o guion bajo | `Usa de 3 a 32 caracteres alfanuméricos, guion o guion bajo.` |
| Código | Único | `Ya existe un producto con el código X.` |
| Nombre | Obligatorio | `El nombre es obligatorio.` |
| Precio de compra | Número no negativo, admite coma o punto | `Ingresa un número válido.` |
| Precio de venta | Número no negativo, admite coma o punto | `Ingresa un número válido.` |
| Stock mínimo | Entero no negativo | `Ingresa un número entero.` |
| Existencias iniciales | Entero no negativo, opcional | `Ingresa un número entero.` |
| Categoría | Selección obligatoria | `Selecciona una categoría.` |

Las validaciones de movimiento viven en
`lib/features/inventory/domain/services/movement_validator.dart` y en la propia
pantalla de movimiento.

| Campo | Regla | Mensaje |
| --- | --- | --- |
| Cantidad de entrada | Mayor que cero | `La cantidad debe ser mayor que cero.` |
| Cantidad de salida | Mayor que cero y no superior al stock | `Stock insuficiente: solo hay N unidades.` |
| Cantidad de ajuste | Entero no negativo | `Ingresa una cantidad válida.` |
| Motivo | Obligatorio | `Selecciona un motivo.` |
| Justificación del ajuste | No vacía | `El ajuste requiere una justificación.` |
| Responsable | Configurado en el perfil | `Configura el responsable en la sección Perfil.` |

## Códigos de error del dominio

Los códigos se definen en `lib/core/error/error_codes.dart`.

| Código | Significado |
| --- | --- |
| `quantity_not_positive` | Cantidad no válida para el movimiento. |
| `insufficient_stock` | Salida superior al stock disponible. |
| `reason_required` | Motivo o responsable obligatorio. |
| `justification_required` | Ajuste sin justificación. |
| `code_duplicated` | Código de producto duplicado. |
| `code_required` | Código de producto inválido. |
| `name_required` | Nombre de producto obligatorio. |
| `price_invalid` | Precio no válido. |
| `min_stock_invalid` | Stock mínimo o inicial no válido. |
| `product_not_found` | Producto inexistente. |
| `product_inactive` | Producto desactivado. |
| `product_has_movements` | Producto con movimientos. |
| `concurrency_conflict` | Conflicto de concurrencia. |
| `storage_failure` | Fallo de almacenamiento. |
| `unexpected` | Error inesperado. |

## Manejo de errores en la interfaz

Los errores del dominio llegan a la interfaz como `DomainException` o
`AppFailure`. La función `showFailureSnackBar`
(`lib/core/widgets/feedback.dart`) traduce el error a un mensaje legible y lo
muestra en una notificación flotante.

- Los errores de dominio muestran su mensaje directo.
- Los errores inesperados muestran `No se pudo completar la operación.`.

## Errores de cámara y permisos

El escáner distingue tres situaciones:

- **Permiso denegado** (`permissionDenied`): mensaje `Permiso de cámara
  denegado` con opción de reintentar.
- **Escaneo no soportado** (`unsupported`): mensaje `Cámara no disponible` y
  acceso a la búsqueda manual.
- **Otro error**: mensaje `No se pudo iniciar la cámara` con opción de
  reintentar.

En todos los casos la búsqueda manual sigue disponible.

## Errores de almacenamiento

- Si la base de datos no se puede preparar al arrancar, la aplicación muestra
  `No se pudo preparar el almacenamiento local` con un botón de reintento.
- Si la exportación a CSV o la captura de la etiqueta fallan, se muestra un
  mensaje de error y la operación se puede repetir.

## Estados de la interfaz

- **Carga**: indicadores de progreso en listas, reportes y formularios.
- **Confirmación**: notificaciones flotantes tras crear, guardar o registrar.
- **Vacío**: mensajes con icono y acción cuando una lista no tiene datos.
- **Error**: mensajes con opción de reintentar cuando falla una consulta.
