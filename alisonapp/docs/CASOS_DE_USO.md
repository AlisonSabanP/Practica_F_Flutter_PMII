# Casos de uso y reglas de negocio

Las reglas de inventario viven en el dominio, en
`lib/features/inventory/domain/services/` y en los casos de uso de
`lib/features/*/domain/usecases/`. No dependen de widgets ni de la base de datos.

## Casos de uso

### Productos

| Caso de uso | Entrada | Salida | Descripción |
| --- | --- | --- | --- |
| `CreateProductUseCase` | `ProductDraft` | `Product` | Valida el borrador, comprueba que el código no esté duplicado y crea el producto. Si hay existencias iniciales, las registra como movimiento de entrada. |
| `UpdateProductUseCase` | `ProductDraft` | `Product` | Valida el borrador y actualiza los datos del producto. No cambia el stock. |
| `DeactivateProductUseCase` | `int id` | `void` | Marca el producto como inactivo. No se elimina si tiene movimientos. |
| `ReactivateProductUseCase` | `int id` | `void` | Reactiva un producto inactivo. |
| `FindProductByCodeUseCase` | `String code` | `Product?` | Busca un producto por su código único. |
| `SearchProductsUseCase` | filtros | `List<Product>` | Búsqueda por nombre o código. |

### Inventario

| Caso de uso | Entrada | Salida | Descripción |
| --- | --- | --- | --- |
| `RegisterMovementUseCase` | `MovementRequest` | `Movement` | Valida la solicitud y delega el registro y la actualización del stock en una única transacción. |
| `GetMovementHistoryUseCase` | `MovementFilter` | `List<Movement>` | Devuelve el historial filtrado por producto, tipo y rango de fechas. |
| `GetLowStockProductsUseCase` | - | `List<Product>` | Lista los productos con existencias iguales o inferiores al mínimo. |

### Reportes

| Caso de uso | Entrada | Salida | Descripción |
| --- | --- | --- | --- |
| `BuildInventoryReportUseCase` | - | `InventoryReport` | Calcula totales de productos, unidades y valor del inventario. |
| `ExportInventoryCsvUseCase` | - | `File` | Genera un archivo CSV con el inventario. |

### Ajustes

| Caso de uso | Entrada | Salida | Descripción |
| --- | --- | --- | --- |
| `GetProfileUseCase` | - | `LocalProfile` | Lee el perfil local. |
| `SaveProfileUseCase` | `LocalProfile` | `void` | Guarda el responsable y el nombre de la tienda. |
| `SeedDemoDataUseCase` | - | `bool` | Carga los datos de demostración una sola vez. |

## Reglas de negocio

Las siguientes reglas se implementan en el dominio y se verifican con pruebas
unitarias e integración.

1. **Cantidades mayores que cero.** Las entradas y salidas deben tener una
   cantidad mayor que cero. Un ajuste admite cero como cantidad contada.
   - Implementada en `StockCalculator.apply` y `MovementValidator.validate`.
   - Código de error: `quantity_not_positive`.

2. **Sin salidas superiores al stock.** Una salida no puede superar las
   existencias disponibles.
   - Implementada en `StockCalculator.apply`.
   - Código de error: `insufficient_stock`.

3. **Sin borrado físico con movimientos.** Un producto con movimientos no se
   elimina; solo se desactiva y conserva su historial.
   - Implementada en `DeactivateProductUseCase` y en la capa de datos.

4. **Movimientos inmutables.** Los movimientos confirmados no se editan ni se
   eliminan. Los errores se corrigen con un nuevo movimiento de ajuste.
   - El dominio expone solo operaciones de creación y consulta de movimientos.

5. **Operación atómica.** El registro del movimiento y la actualización del
   stock se ejecutan dentro de una única transacción.
   - Implementada en `DriftMovementRepository.registerMovement` y en
     `DriftProductRepository.createProduct`.

6. **Justificación obligatoria en ajustes.** Un ajuste exige una justificación
   no vacía.
   - Implementada en `StockCalculator.apply` y `MovementValidator.validate`.
   - Código de error: `justification_required`.

7. **Código único.** No se permiten dos productos con el mismo código.
   - Implementada en `CreateProductUseCase` y reforzada con una restricción
     `unique` en la tabla `products`.
   - Código de error: `code_duplicated`.

8. **Producto inactivo sin movimientos.** Un producto desactivado no admite
   nuevos movimientos.
   - Implementada en `DriftMovementRepository.registerMovement`.
   - Código de error: `product_inactive`.

## Cálculo del stock

`StockCalculator.apply` recibe el tipo, la cantidad y el stock actual, y
devuelve un `StockChange` con el stock anterior y el resultante.

- **Entrada**: `resultante = actual + cantidad`.
- **Salida**: `resultante = actual - cantidad`, siempre que
  `cantidad <= actual`.
- **Ajuste**: `resultante = cantidad contada`.

## Valor del inventario

El valor del inventario se estima como `suma(existencias × precio de compra)`.
Es una estimación simple y no aplica métodos contables como promedio ponderado o
FIFO.
