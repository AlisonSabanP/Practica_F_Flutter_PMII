# 05. Funcionalidades, casos de uso, gestión de estado y flujo de información

## 1. Vista general de funcionalidades

La aplicación se organiza en cinco secciones accesibles desde la barra de navegación inferior (`HomeShell`):

| Sección | Pantalla principal | Funcionalidad |
|---|---|---|
| Inicio | `HomeScreen` | Resumen del inventario, métricas, alertas de stock y accesos rápidos. |
| Productos | `ProductsScreen` | Catálogo con búsqueda, filtros (categoría, stock bajo, inactivos) y creación de productos. |
| Escáner | `ScannerScreen` | Lectura de códigos de barras/QR con cámara y búsqueda manual por código o nombre. |
| Historial | `HistoryScreen` | Historial de movimientos con filtros y exportación del inventario a CSV. |
| Perfil | `ProfileScreen` | Configuración del responsable y tienda; información del almacenamiento local. |

Además, desde cualquier producto se accede a:
- **Detalle del producto** (`ProductDetailScreen`): existencias, valor, etiqueta (código de barras + QR), movimientos recientes, registro de movimiento, desactivar/reactivar.
- **Formulario de producto** (`ProductFormScreen`): crear o editar producto.
- **Registro de movimiento** (`MovementScreen`): entrada, salida o ajuste de existencias.

## 2. Casos de uso por feature

### Products (`features/products/domain/usecases/`)

| Caso de uso | Propósito | Reglas de dominio aplicadas |
|---|---|---|
| `CreateProductUseCase` | Crea un producto y registra existencias iniciales como entrada. | `ProductValidator.assertValid`, unicidad de código (`codeDuplicated`). |
| `UpdateProductUseCase` | Edita datos de un producto (nunca modifica el stock). | `ProductValidator.assertValid`, unicidad excluyendo el propio id. |
| `FindProductByCodeUseCase` | Busca producto por código único. | Código no vacío (`codeRequired`). |
| `SearchProductsUseCase` | Filtra productos por texto (código, nombre, descripción). | Sin restricciones de negocio. |
| `DeactivateProductUseCase` | Desactiva un producto (borrado lógico; conserva historial). | — |
| `ReactivateProductUseCase` | Reactiva un producto desactivado. | Producto debe existir (`productNotFound`). |

### Inventory (`features/inventory/domain/usecases/`)

| Caso de uso | Propósito | Reglas de dominio aplicadas |
|---|---|---|
| `RegisterMovementUseCase` | Registra entrada/salida/ajuste y actualiza el stock atómicamente. | `MovementValidator.validate`, responsable no vacío, stock insuficiente, producto inactivo/inexistente. |
| `GetMovementHistoryUseCase` | Consulta historial de movimientos con filtros. | — |
| `GetLowStockProductsUseCase` | Lista productos con `stockActual <= minStock`. | — |

### Reports (`features/reports/domain/usecases/`)

| Caso de uso | Propósito | Reglas de dominio aplicadas |
|---|---|---|
| `BuildInventoryReportUseCase` | Calcula el resumen agregado del inventario. | — |
| `ExportInventoryCsvUseCase` | Exporta el catálogo a CSV y lo comparte. | — |

### Settings (`features/settings/domain/usecases/`)

| Caso de uso | Propósito | Reglas de dominio aplicadas |
|---|---|---|
| `SaveProfileUseCase` | Guarda el perfil local (responsable, tienda). | Responsable y tienda normalizados (trim). |
| `GetProfileUseCase` | Lee el perfil local (stream o futuro). | — |
| `SeedDemoDataUseCase` | Carga datos de demostración si la base está vacía. | Idempotente. |

## 3. Servicios de reglas de negocio (dominio puro)

### `StockCalculator` (inventario)
- `apply({type, quantity, currentStock, justification})`: devuelve `StockChange(previousStock, resultingStock)`.
- Reglas: entrada > 0; salida > 0 y ≤ currentStock (sino `insufficient_stock`); ajuste fija stock y exige justificación (`justification_required`); cantidad máxima 1 000 000; no negativas.
- No depende de UI ni de base de datos.

### `MovementValidator` (inventario)
- Valida cantidad ≥ 0, cantidad > 0 para entrada/salida, motivo no vacío, responsable no vacío, justificación obligatoria en ajuste.

### `ProductValidator` (productos)
- Valida código (formato `^[A-Za-z0-9\-_]{3,32}$`), nombre no vacío, precios numéricos ≥ 0, stock mínimo entero ≥ 0, existencias iniciales opcionales ≥ 0.
- `parseDecimal` acepta coma o punto como separador decimal.

### `CsvBuilder` (reportes)
- Construye CSV RFC 4180 con escape de campos. Encabezados: código, nombre, categoría, descripción, precios, stock, estado, activo, valor.

## 4. Gestión de estado (Riverpod)

El estado de la aplicación se maneja exclusivamente con **Riverpod**, sin `setState` global ni singletons de negocio.

### Proveedores de consulta reactiva (Streams)

```dart
productsProvider          → Stream<List<Product>>      (activos, ordenados por nombre)
allProductsProvider       → Stream<List<Product>>      (incluye inactivos)
lowStockProvider          → Stream<List<Product>>      (stock ≤ mínimo)
categoriesProvider        → Stream<List<Category>>     (ordenadas por nombre)
movementHistoryProvider   → StreamProvider.family      (historial filtrado por MovementFilter)
profileProvider           → Stream<LocalProfile>       (perfil local)
```

### Proveedores de consulta puntual (Futures)

```dart
inventoryReportProvider   → Future<InventoryReport>    (resumen agregado)
productByIdProvider       → FutureProvider.family      (producto por id)
productByCodeProvider     → FutureProvider.family      (producto por código)
```

### Proveedores de casos de uso y repositorios

Todos los repositorios (`ProductRepository`, `MovementRepository`, …) y casos de uso se registran como `Provider` en `core/providers.dart`, inyectando `AppDatabase` y dependencias entre sí. Esto permite sustituir implementaciones en pruebas (base de datos en memoria).

### Filtro del historial

`MovementFilterNotifier` (NotifierProvider) gestiona el filtro activo (producto, tipo, rango de fechas) con métodos `setProduct`, `setType`, `setDateRange`, `clear`.

## 5. Flujo de información (ejemplos representativos)

### Flujo A — Registrar una salida de existencias

```
Usuario toca "Salida" en ProductDetailScreen
      ↓
MovementScreen (producto, tipo inicial = salida)
      ↓
Usuario ingresa cantidad, motivo, responsable (desde perfil)
      ↓
MovementScreen llama registerMovementUseCase(MovementRequest)
      ↓
RegisterMovementUseCase valida con MovementValidator
      ↓
DriftMovementRepository (transacción SQLite):
   - verifica producto existente y activo
   - StockCalculator.apply(salida, qty, stockActual) → StockChange
   - inserta en Movimientos + actualiza Products.stockActual
      ↓
Retorna Movement → navega de vuelta (pop true)
      ↓
ProductDetailScreen invalida productByIdProvider → se refresca stock y movimientos
```

### Flujo B — Escanear un código y ver el producto

```
Usuario toca "Escanear código" en Home
      ↓
ScannerScreen inicia cámara (mobile_scanner, formatos Code128 + QR)
      ↓
Cámara detecta código → _resolveCode(raw)
      ↓
findProductByCodeUseCase(code) → Product? (o null)
      ↓
Si existe → muestra bottom sheet "Producto encontrado" con ProductTile
      ↓
Usuario toca "Ver detalle y registrar movimiento" → ProductDetailScreen
```

### Flujo C — Exportar inventario a CSV

```
Usuario toca "Exportar inventario a CSV" en HistoryScreen
      ↓
exportInventoryCsvUseCase() → obtiene productos (getInventorySnapshot)
      ↓
CsvBuilder.inventoryCsv(products) → texto CSV RFC 4180
      ↓
FileExporter.writeTextFile → guarda en carpeta exportaciones/
      ↓
sharePlus.shareFile → comparte el CSV con otras apps
```

## 6. Consistencia y reactividad

- Las pantallas que muestran stock (`HomeScreen`, `ProductDetailScreen`, `ProductsScreen`) escuchan `StreamProvider`s, por lo que se actualizan automáticamente cuando se registra un movimiento.
- Después de un movimiento exitoso, la pantalla de detalle invalida `productByIdProvider` para forzar la recarga inmediata.
- Las exportaciones y etiquetas se escriben en el almacenamiento interno de la app (no requieren permisos de almacenamiento en Android) y se comparten con `share_plus`.
