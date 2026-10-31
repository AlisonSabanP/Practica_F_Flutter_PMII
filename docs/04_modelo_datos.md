# 04. Modelo de datos, diccionario de campos, relaciones y persistencia

## 1. Persistencia

- **Motor:** SQLite local mediante **Drift** (antes Moor).
- **Archivo:** `inventario.sqlite` en el directorio de documentos de la app (`path_provider.getApplicationDocumentsDirectory`).
- **Esquema:** versión 1, tablas definidas en `core/database/app_database.dart`.
- **Integridad:** claves foráneas habilitadas (`PRAGMA foreign_keys = ON`). Las categorías son referenciadas por los productos; los movimientos por los productos.
- **Transacciones:** creación de producto con existencias iniciales y registro de movimientos usan transacciones atómicas de Drift.
- **Conexión:** `LazyDatabase` que abre la base en segundo plano; se cierra al.dispose del provider.

## 2. Tablas del esquema

| Tabla | Clave principal | Descripción |
|---|---|---|
| `Categories` | `id` (autoincremental) | Catálogo de categorías de productos. |
| `Products` | `id` (autoincremental) | Catálogo de productos. `code` es único. `stockActual` es derivado (solo cambia por movimientos). |
| `Movements` | `id` (autoincremental) | Historial inmutable de movimientos de inventario. |
| `Profiles` | `id` (= 1) | Perfil local único: responsable, tienda y bandera de datos demo cargados. |

### Columnas de cada tabla

#### `Categories`
| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | Integer | PK, autoincremental | Identificador de categoría. |
| `name` | Text | NOT NULL, 1-80 chars | Nombre de la categoría (ej. "Bebidas"). |

#### `Products`
| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | Integer | PK, autoincremental | Identificador de producto. |
| `code` | Text | UNIQUE, NOT NULL, 1-32 chars | Código único del producto (usado en código de barras y QR). |
| `name` | Text | NOT NULL, 1-120 chars | Nombre del producto. |
| `description` | Text | DEFAULT '' | Descripción opcional. |
| `categoryId` | Integer | FK → Categories.id | Categoría a la que pertenece. |
| `purchasePrice` | Real | DEFAULT 0 | Precio de compra. |
| `salePrice` | Real | DEFAULT 0 | Precio de venta. |
| `stockActual` | Integer | DEFAULT 0 | Existencias actuales (derivado, solo por movimientos). |
| `minStock` | Integer | DEFAULT 0 | Stock mínimo para alerta. |
| `photoPath` | Text | NULLABLE | Ruta de la foto opcional del producto. |
| `active` | Boolean | DEFAULT true | Indica si el producto está activo (borrado lógico). |

#### `Movements`
| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | Integer | PK, autoincremental | Identificador del movimiento. |
| `productId` | Integer | FK → Products.id | Producto afectado. |
| `type` | Text | NOT NULL, 1-10 chars | Tipo: "entrada", "salida" o "ajuste". |
| `quantity` | Integer | NOT NULL | Cantidad del movimiento. |
| `previousStock` | Integer | NOT NULL | Stock antes del movimiento. |
| `resultingStock` | Integer | NOT NULL | Stock después del movimiento. |
| `reason` | Text | NOT NULL, 1-200 chars | Motivo (Compra, Venta, Conteo físico, etc.). |
| `responsible` | Text | NOT NULL, 1-120 chars | Responsable del movimiento. |
| `occurredAt` | DateTime | NOT NULL | Fecha y hora del movimiento. |

#### `Profiles`
| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | Integer | PK (valor fijo 1) | Identificador de fila única. |
| `responsibleName` | Text | DEFAULT '' | Nombre del responsable por defecto. |
| `storeName` | Text | DEFAULT '' | Nombre de la tienda/bodega. |
| `seeded` | Boolean | DEFAULT false | Indica si los datos de demostración ya se cargaron. |

## 3. Relaciones

```
Categories 1 ──∞ Products   (categoryId FK)
Products    1 ──∞ Movements (productId FK)
Profiles    1 ──1  (fila singleton, id = 1)
```

- Un producto pertenece a una categoría. Si se elimina una categoría (no permitido por la UI actual), Drift respetaría la FK.
- Un producto puede tener muchos movimientos; cada movimiento pertenece a un producto.
- Los movimientos son inmunes a cambios de producto: si un producto se desactiva, sus movimientos se conservan.

## 4. Entidades de dominio (diccionario de campos)

### `Product`
| Campo | Tipo | Descripción |
|---|---|---|
| `id` | int | Identificador persistido. |
| `code` | String | Código único (Code 128 / QR). |
| `name` | String | Nombre del producto. |
| `description` | String | Descripción opcional. |
| `categoryId` | int | ID de categoría. |
| `purchasePrice` | double | Precio de compra. |
| `salePrice` | double | Precio de venta. |
| `stockActual` | int | Existencias actuales (derivado). |
| `minStock` | int | Stock mínimo de alerta. |
| `photoPath` | String? | Ruta de foto opcional. |
| `active` | bool | ¿Producto activo? |
| `category` | Category? | Categoría resuelta (solo consultas). |

Propiedades derivadas:
- `isLowStock` → `stockActual <= minStock`
- `isOutOfStock` → `stockActual <= 0`
- `inventoryValue` → `stockActual * purchasePrice`
- `stockStatus` → `StockStatus.ok / low / outOfStock`

### `Category`
| Campo | Tipo | Descripción |
|---|---|---|
| `id` | int | Identificador. |
| `name` | String | Nombre de la categoría. |

### `Movement`
| Campo | Tipo | Descripción |
|---|---|---|
| `id` | int | Identificador. |
| `productId` | int | Producto afectado. |
| `type` | MovementType | entrada / salida / ajuste. |
| `quantity` | int | Cantidad del movimiento. |
| `previousStock` | int | Stock antes. |
| `resultingStock` | int | Stock después. |
| `reason` | String | Motivo. |
| `responsible` | String | Responsable. |
| `dateTime` | DateTime | Fecha y hora. |
| `productCode` | String? | Código del producto (para historial). |
| `productName` | String? | Nombre del producto (para historial). |
| `delta` | int | `resultingStock - previousStock` (solo lectura). |

### `MovementType` (enum)
| Valor | Código | `increasesStock` | `decreasesStock` | Etiqueta |
|---|---|---|---|---|
| `entrada` | "entrada" | sí | no | Entrada |
| `salida` | "salida" | no | sí | Salida |
| `ajuste` | "ajuste" | no | no | Ajuste |

### `MovementRequest` (entrada de casos de uso)
| Campo | Tipo | Descripción |
|---|---|---|
| `productId` | int | Producto objetivo. |
| `type` | MovementType | Tipo de movimiento. |
| `quantity` | int | Cantidad (para ajuste: cantidad contada = nuevo stock). |
| `reason` | String | Motivo. |
| `responsible` | String | Responsable. |
| `justification` | String? | Justificación obligatoria solo en ajuste. |

### `InventoryReport`
| Campo | Tipo | Descripción |
|---|---|---|
| `totalProducts` | int | Total de productos en el catálogo. |
| `activeProducts` | int | Productos activos. |
| `inactiveProducts` | int | Productos inactivos. |
| `totalUnits` | int | Suma de `stockActual`. |
| `totalValue` | double | Suma de `inventoryValue` (precio de compra). |
| `lowStockCount` | int | Productos activos con stock bajo. |
| `outOfStockCount` | int | Productos activos sin existencias. |

### `LocalProfile`
| Campo | Tipo | Descripción |
|---|---|---|
| `responsibleName` | String | Nombre del responsable. |
| `storeName` | String | Nombre de tienda/bodega. |
| `seeded` | bool | ¿Datos demo cargados? |
| `isConfigured` | bool (derivado) | ¿responsibleName no vacío? |

### `ProductDraft` (formulario de crear/editar)
| Campo | Tipo | Descripción |
|---|---|---|
| `id` | int? | Null al crear, presente al editar. |
| `code`, `name`, `description` | String | Datos del producto. |
| `categoryId` | int | Categoría. |
| `purchasePrice`, `salePrice` | double | Precios. |
| `minStock` | int | Stock mínimo. |
| `photoPath` | String? | Foto opcional. |
| `initialStock` | int | Existencias iniciales (solo al crear; se registra como entrada). |
| `active` | bool | ¿Activo? |
| `responsible` | String | Responsable del movimiento inicial. |
| `isEditing` | bool (derivado) | `id != null`. |

## 5. Mappers (datos → dominio)

| Mapper | Origen → Destino | Ubicación |
|---|---|---|
| `ProductMapper.fromRow` | `ProductRow` + `CategoryRow?` → `Product` | `products/data/product_mapper.dart` |
| `CategoryMapper.fromRow` | `CategoryRow` → `Category` | `products/data/product_mapper.dart` |
| `MovementMapper.fromRow` | `MovementRow` + `ProductRow?` → `Movement` | `inventory/data/movement_mapper.dart` |

## 6. Flujo de persistencia de un movimiento

1. La UI llama a `RegisterMovementUseCase` con un `MovementRequest`.
2. `DriftMovementRepository.registerMovement` abre una transacción (`_db.transaction`).
3. Valida que el producto exista y esté activo.
4. Calcula el nuevo stock con `StockCalculator.apply` (dominio).
5. Inserta la fila en `Movements` y actualiza `stockActual` en `Products` dentro de la misma transacción.
6. Si cualquier paso falla, se revierte todo (atomicidad): ni se registra el movimiento ni se altera el stock.
7. Devuelve la entidad `Movement` con `id`, fechas y datos del producto.

## 7. Datos de demostración (seed)

Cargados por `DemoDataSeeder` (`settings/data/demo_data_seeder.dart`), de forma idempotente (solo si la base está vacía):

- **3 categorías:** Bebidas, Abarrotes, Aseo y limpieza.
- **15 productos** (códigos `P0000000001`…`P00000000015`), 5 por categoría, cada uno con precios, stock mínimo y existencias iniciales registradas como movimiento de entrada ("Existencias iniciales", responsable "Administrador", hace 7 días).

Véase `docs/01_objetivo_alcance.md` §5 para el listado completo de los 15 productos.
