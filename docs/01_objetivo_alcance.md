# 01. Objetivo, alcance, requisitos y reglas de negocio

## 1. Objetivo

Proveer una aplicación móvil para Android que permita a una tienda o bodega gestionar su inventario de forma sencilla, rápida y sin conexión a internet, mediante:

- Registro y edición de productos con categoría, precios y stock mínimo.
- Lectura y generación de códigos de barras (Code 128) y QR para identificar productos.
- Registro de movimientos de inventario: **entradas**, **salidas** y **ajustes**.
- Control de existencias con alertas de stock bajo y agotado.
- Consulta del historial de movimientos y exportación del inventario a CSV.

La aplicación está pensada para un único responsable por dispositivo (perfil local) y opera de modo **offline-first**: todos los datos residen en una base de datos SQLite local.

## 2. Alcance

### Incluido

| Ámbito | Alcance |
|---|---|
| Plataforma | Android (APK de release). iOS/web no son objetivo de esta entrega. |
| Usuarios | Un responsable por dispositivo (configurado en Perfil). No hay autenticación multiusuario ni roles. |
| Almacenamiento | SQLite local (`inventario.sqlite`) en el directorio de documentos de la app. No requiere servidor. |
| Productos | Crear, editar, desactivar/reactivar y consultar. Cada producto tiene código único, nombre, descripción, categoría, precios (compra/venta), stock mínimo, stock actual y foto opcional. |
| Categorías | Catálogo de categorías para agrupar productos. |
| Movimientos | Entrada, salida y ajuste. Cada movimiento queda registrado inmutablemente (no se edita ni se elimina). |
| Códigos | Generación de etiquetas imprimibles con código de barras Code 128 y QR (ambos codifican el código único del producto). Lectura por cámara con búsqueda manual de respaldo. |
| Reportes | Resumen del inventario (productos, unidades, valor, alertas), historial de movimientos con filtros y exportación a CSV. |
| Demo | Carga automática de 3 categorías y 15 productos con existencias iniciales la primera vez. |

### No incluido (fuera de alcance)

- Sincronización con la nube o servidor remoto.
- Autenticación de múltiples usuarios con contraseña y roles.
- Impresión directa a impresora física (las etiquetas se exportan como imagen PNG y se comparten).
- Módulo de compras/ventas integrado con pagos.
- Soporte oficial para iOS o Web (el código puede compilarse, pero el alcance de pruebas es Android).

## 3. Requisitos

### Requisitos funcionales

| ID | Requisito |
|---|---|
| RF-01 | El sistema debe permitir crear productos con código único válido. |
| RF-02 | El sistema debe permitir editar datos de un producto (excepto el stock, que solo cambia por movimientos). |
| RF-03 | El sistema debe permitir desactivar/reactivar productos sin borrar su historial. |
| RF-04 | El sistema debe permitir registrar entradas, salidas y ajustes de existencias. |
| RF-05 | El sistema debe impedir salidas superiores al stock disponible. |
| RF-06 | El sistema debe exigir justificación para los ajustes de inventario. |
| RF-07 | El sistema debe exigir un responsable configurado antes de registrar movimientos. |
| RF-08 | El sistema debe generar etiquetas con código de barras y QR por producto. |
| RF-09 | El sistema debe leer códigos de barras/QR mediante la cámara y localizar el producto. |
| RF-10 | El sistema debe ofrecer búsqueda manual por código o nombre si la cámara no está disponible. |
| RF-11 | El sistema debe mostrar alertas de stock bajo y agotado. |
| RF-12 | El sistema debe consultar el historial de movimientos con filtros (producto, tipo, fechas). |
| RF-13 | El sistema debe exportar el inventario completo a CSV y compartir el archivo. |
| RF-14 | El sistema debe funcionar sin conexión a internet. |

### Requisitos no funcionales

| ID | Requisito |
|---|---|
| RNF-01 | Todas las reglas de inventario residen en el dominio, independientes de la UI y de la base de datos. |
| RNF-02 | Registro atómico: el movimiento y la actualización del stock se guardan en una sola transacción. |
| RNF-03 | Inmutabilidad de movimientos: un movimiento confirmado nunca se edita ni se elimina. |
| RNF-04 | Consulta reactiva: pantallas se actualizan automáticamente ante cambios de stock (Streams/ Riverpod). |
| RNF-05 | Tiempos de respuesta de consultas locales inferiores a 1 s en dispositivo medio. |
| RNF-06 | Manejo graceful de errores de cámara y almacenamiento con mensajes al usuario. |

## 4. Reglas de negocio

### RB-01 — Unicidad del código
El código de producto debe ser único en el catálogo. Al crear o editar, se valida que no exista otro producto con el mismo código (`ErrorCodes.codeDuplicated`).

### RB-02 — Stock solo por movimientos
El `stockActual` de un producto **no se modifica al editar el producto**. Solo cambia al registrar un movimiento confirmado (entrada, salida o ajuste). Las existencias iniciales al crear un producto se registran como una entrada automática.

### RB-03 — Entrada
- Cantidad obligatoria y mayor que cero.
- Aumenta el stock: `resultingStock = previousStock + quantity`.

### RB-04 — Salida
- Cantidad obligatoria y mayor que cero.
- No puede superar el stock disponible (`previousStock`). De lo contrario, falla con `ErrorCodes.insufficient_stock` y no se registra nada (atomicidad).

### RB-05 — Ajuste
- La cantidad es el nuevo stock contado (pasa a ser el `resultingStock`).
- Exige justificación no vacía (`ErrorCodes.justification_required`).
- Puede aumentar o disminuir el stock.

### RB-06 — Responsable
Todo movimiento debe registrar un `responsible` no vacío, tomado del perfil local configurado.

### RB-07 — Producto inactivo
Un producto desactivado no admite movimientos nuevos (`ErrorCodes.product_inactive`), pero su historial se conserva.

### RB-08 — Borrado lógico
Los productos nunca se eliminan físicamente si tienen movimientos asociados; se desactivan (borrado lógico).

### RB-09 — Límites defensivos
- Cantidad máxima por movimiento: 1 000 000 unidades (`StockCalculator.maxQuantity`).
- Cantidades negativas son rechazadas.

### RB-10 — Código de barras / QR
El código de barras (Code 128) y el QR codifican exclusivamente el **código único del producto** (ej. `P0000000001`). Cantidades y existencias no se codifican porque cambian con cada movimiento.

---

## 5. Datos de demostración (incluidos)

Cargados automáticamente la primera vez (idempotente):

- **3 categorías:** Bebidas, Abarrotes, Aseo y limpieza.
- **15 productos** con códigos `P0000000001` a `P00000000015`, precios de compra y venta, stock mínimo y existencias iniciales (movimiento de entrada "Existencias iniciales").
- Responsable por defecto: `Administrador`; tienda: `Bodega principal`.

Detalle completo en `docs/04_modelo_datos.md` y en el seedero `alisonapp/lib/features/settings/data/demo_data_seeder.dart`.
