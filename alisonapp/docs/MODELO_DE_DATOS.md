# Modelo de datos

La base de datos local es SQLite, gestionada con Drift. Todas las tablas se
definen en `lib/core/database/app_database.dart`.

## Diagrama de relaciones

```
Categories 1 --- N Products 1 --- N Movements
Profiles (una sola fila, id = 1)
```

- Una categoría agrupa muchos productos.
- Un producto pertenece a una categoría y acumula muchos movimientos.
- El perfil local es un registro único con el responsable por defecto.

## Tabla `categories`

| Campo | Tipo | Nulo | Reglas | Descripción |
| --- | --- | --- | --- | --- |
| id | INTEGER | No | Clave primaria, autoincremental | Identificador de la categoría. |
| name | TEXT | No | Longitud 1 a 80 | Nombre de la categoría. |

## Tabla `products`

| Campo | Tipo | Nulo | Reglas | Descripción |
| --- | --- | --- | --- | --- |
| id | INTEGER | No | Clave primaria, autoincremental | Identificador del producto. |
| code | TEXT | No | Único, longitud 1 a 32 | Código único del producto. Origen del código de barras y del QR. |
| name | TEXT | No | Longitud 1 a 120 | Nombre del producto. |
| description | TEXT | No | Por defecto vacío | Descripción libre. |
| category_id | INTEGER | No | Clave foránea a `categories.id` | Categoría del producto. |
| purchase_price | REAL | No | Por defecto 0 | Precio de compra. Se usa para valorar el inventario. |
| sale_price | REAL | No | Por defecto 0 | Precio de venta. |
| stock_actual | INTEGER | No | Por defecto 0 | Existencias actuales. Solo cambia mediante movimientos confirmados. |
| min_stock | INTEGER | No | Por defecto 0 | Stock mínimo para alertas. |
| photo_path | TEXT | Sí | - | Ruta de la fotografía opcional. |
| active | BOOLEAN | No | Por defecto verdadero | Un producto inactivo no admite movimientos. |

## Tabla `movements`

| Campo | Tipo | Nulo | Reglas | Descripción |
| --- | --- | --- | --- | --- |
| id | INTEGER | No | Clave primaria, autoincremental | Identificador del movimiento. |
| product_id | INTEGER | No | Clave foránea a `products.id` | Producto afectado. |
| type | TEXT | No | `entrada`, `salida` o `ajuste` | Tipo de movimiento. |
| quantity | INTEGER | No | Ver reglas de negocio | Cantidad de entrada o salida, o cantidad contada en un ajuste. |
| previous_stock | INTEGER | No | - | Existencias antes del movimiento. |
| resulting_stock | INTEGER | No | - | Existencias después del movimiento. |
| reason | TEXT | No | Longitud 1 a 200 | Motivo del movimiento. |
| responsible | TEXT | No | Longitud 1 a 120 | Responsable que registra el movimiento. |
| occurred_at | DATETIME | No | - | Fecha y hora del movimiento. |

## Tabla `profiles`

| Campo | Tipo | Nulo | Reglas | Descripción |
| --- | --- | --- | --- | --- |
| id | INTEGER | No | Clave primaria, valor fijo 1 | Identificador del registro único. |
| responsible_name | TEXT | No | Por defecto vacío | Responsable por defecto de los movimientos. |
| store_name | TEXT | No | Por defecto vacío | Nombre de la tienda o bodega. |
| seeded | BOOLEAN | No | Por defecto falso | Indica si ya se cargaron los datos de demostración. |

## Reglas sobre las existencias

- `products.stock_actual` es un valor derivado. Nunca se edita directamente.
- Las existencias iniciales de un producto se registran como un movimiento de
  entrada, no como un valor directo en la tabla.
- Cada movimiento guarda `previous_stock` y `resulting_stock`, de modo que el
  historial es auditable y consistente.

## Integridad referencial

Las claves foráneas se activan con `PRAGMA foreign_keys = ON` al abrir la base
de datos. Un producto no se elimina físicamente cuando tiene movimientos: se
marca como inactivo para conservar el historial.
