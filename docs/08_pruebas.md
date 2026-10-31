# 08. Pruebas realizadas, pasos de reproducción, resultados y evidencias

## 1. Resumen de pruebas

Se ejecutaron pruebas unitarias de dominio y pruebas de widgets. Todas las pruebas pasan.

```
flutter test test/domain/   →  42 tests, todos pasan (OK)
flutter test test/widget_test.dart →  2 tests, todos pasan (OK)
```

**Total:** 44 pruebas, 0 fallos.

## 2. Pruebas de reglas de inventario (evidencia principal)

Las reglas de inventario residen en el dominio y están probadas de forma aislada (sin UI ni base de datos real), usando `AppDatabase.forTesting(NativeDatabase.memory())` para los flujos de integración.

### 2.1 StockCalculator (`test/domain/stock_calculator.test.dart`)

Archivo: `alisonapp/test/domain/stock_calculator_test.dart`

| Caso | Tipo de movimiento | Entrada | Resultado esperado | Código de error |
|---|---|---|---|---|
| Suma entrada | entrada | qty=20, stock=5 | previous=5, resulting=25, delta=20 | — |
| Rechaza entrada cero | entrada | qty=0, stock=5 | lanza `DomainException` | `quantity_not_positive` |
| Rechaza entrada negativa | entrada | qty=-3, stock=5 | lanza `DomainException` | `quantity_not_positive` |
| Descuenta salida | salida | qty=16, stock=20 | previous=20, resulting=4, delta=-16 | — |
| Salida deja stock en cero | salida | qty=20, stock=20 | resulting=0 | — |
| Rechaza salida insuficiente | salida | qty=5, stock=4 | lanza `DomainException` | `insufficient_stock` |
| Rechaza salida cero | salida | qty=0, stock=10 | lanza `DomainException` | `quantity_not_positive` |
| Ajuste fija stock | ajuste | qty=3, stock=4, justificación | previous=4, resulting=3, delta=-1 | — |
| Ajuste a cero con justificación | ajuste | qty=0, stock=7, justificación | resulting=0 | — |
| Ajuste sin justificación | ajuste | qty=3, stock=4, justificación='' | lanza `DomainException` | `justification_required` |

### 2.2 MovementValidator (`test/domain/movement_validator_test.dart`)

Archivo: `alisonapp/test/domain/movement_validator_test.dart`

| Caso | Resultado |
|---|---|
| Entrada válida (qty=5, motivo, responsable) | aceptada (`returnsNormally`) |
| Entrada cantidad cero | rechazada (`quantity_not_positive`) |
| Salida cantidad cero | rechazada (`quantity_not_positive`) |
| Motivo vacío | rechazada (`reason_required`) |
| Responsable vacío | rechazada (`reason_required`) |
| Ajuste sin justificación | rechazada (`justification_required`) |
| Ajuste con justificación | aceptada (`returnsNormally`) |
| Motivos sugeridos por tipo | cada tipo devuelve lista no vacía |

### 2.3 ProductValidator (`test/domain/product_validator_test.dart`)

Archivo: `alisonapp/test/domain/product_validator_test.dart`

| Campo | Caso válido | Caso inválido |
|---|---|---|
| Código | `ABC-123_x` válido | `''`, `ab` (muy corto), `código con espacios` (inválido) |
| Nombre | `Arroz` válido | `   ` (vacío) |
| Precio | `12.50`, `12,50` válidos | `abc`, `-1` |
| Stock mínimo | `5` válido | `x`, `-2` |
| Existencias iniciales | `''`, `20` válidos | `abc`, `-1` |

`assertValid`: acepta borrador correcto; rechaza precio negativo, stock mínimo negativo, existencias iniciales negativas.

### 2.4 Flujo de inventario integrado (`test/domain/inventory_flow_test.dart`)

Archivo: `alisonapp/test/domain/inventory_flow_test.dart` (base de datos en memoria)

| Grupo | Caso | Qué verifica |
|---|---|---|
| createProduct | guarda existencias iniciales como movimiento de entrada | crear con initialStock=20 → stock=20 y 1 movimiento de entrada qty=20 |
| createProduct | no registra movimiento sin existencias iniciales | initialStock=0 → stock=0 y 0 movimientos |
| createProduct | rechaza código duplicado | crear dos veces mismo código → `code_duplicated` |
| registerMovement | entrada, salida, alerta y ajuste conservan el historial | entrada 20 → salida 16 (quedan 4, bajo mínimo) → rechaza salida de 5 con solo 4 (`insufficient_stock`, stock no cambia) → ajuste a 3 con justificación → historial de 3 movimientos |
| registerMovement | el ajuste exige justificación | ajuste sin justificación → `justification_required` |
| registerMovement | rechaza productos desactivados | producto desactivado → `product_inactive` |
| registerMovement | rechaza productos inexistentes | productId=9999 → `product_not_found` |
| atomicidad | salida fallida no altera stock ni deja movimiento | salida de 10 con stock 4 falla → stock sigue 4 y countMovements sin cambios |
| desactivación | producto con movimientos se desactiva sin borrar historial | desactivar → active=false, countMovements=1, no aparece en productos activos |
| consultas y reportes | filtra historial por tipo | entradas y salidas contadas por separado |
| consultas y reportes | lista productos con stock bajo | de 2 productos, solo el que tiene stock ≤ mínimo |
| consultas y reportes | filtra historial por rango de fechas | rango futuro vacío, rango pasado incluye movimientos |

## 3. Pruebas de widget (`test/widget_test.dart`)

Archivo: `alisonapp/test/widget_test.dart`

| Caso | Resultado |
|---|---|
| La app construye el MaterialApp con título "INVENTARIO" y Material 3 | pasa |
| `EmptyState` muestra título, mensaje y acción | pasa |

## 4. Pasos de reproducción

Desde la raíz del proyecto Flutter (`alisonapp/`):

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Generar código de Drift (requerido por las pruebas que usan AppDatabase)
flutter pub run build_runner build

# 3. Ejecutar todas las pruebas de dominio (incluidas las reglas de inventario)
flutter test test/domain/

# 4. Ejecutar pruebas de widget
flutter test test/widget_test.dart

# 5. Ejecutar todo el conjunto de pruebas
flutter test
```

## 5. Resultados obtenidos (evidencia de consola)

Todas las pruebas finalizaron con `All tests passed!`. A continuación se muestra el resumen del ejecutor de pruebas (transcripción real):

```
00:02 +42: All tests passed!
```

para `test/domain/` (42 pruebas), y

```
00:01 +2: All tests passed!
```

para `test/widget_test.dart` (2 pruebas).

## 6. Evidencia de cobertura de reglas de inventario

| Regla de inventario | ¿Probada? | Archivo de prueba |
|---|---|---|
| Entrada aumenta el stock | Sí | stock_calculator_test.dart |
| Salida descuenta el stock | Sí | stock_calculator_test.dart |
| Rechaza salida superior al stock (`insufficient_stock`) | Sí | stock_calculator_test.dart + inventory_flow_test.dart |
| Rechaza cantidades cero/negativas | Sí | stock_calculator_test.dart, movement_validator_test.dart |
| Ajuste fija el stock a la cantidad contada | Sí | stock_calculator_test.dart |
| Ajuste exige justificación (`justification_required`) | Sí | stock_calculator_test.dart, movement_validator_test.dart, inventory_flow_test.dart |
| Cantidad máxima defensiva (1 000 000) | Sí | stock_calculator_test.dart (código) |
| Movimiento sobre producto desactivado (`product_inactive`) | Sí | inventory_flow_test.dart |
| Movimiento sobre producto inexistente (`product_not_found`) | Sí | inventory_flow_test.dart |
| Atomicidad: fallo no deja movimiento ni altera stock | Sí | inventory_flow_test.dart |
| Existencias iniciales se registran como entrada | Sí | inventory_flow_test.dart |
| Código duplicado (`code_duplicated`) | Sí | inventory_flow_test.dart + product_validator_test.dart |
| Productos con stock bajo | Sí | inventory_flow_test.dart |

## 7. Limitaciones del conjunto de pruebas

- No hay pruebas de integración de pantalla completa (pruebas de navegación end-to-end) porque el escáner requiere cámara y no es determinista en entorno de pruebas unitarias.
- La cobertura se centra en el dominio, que es donde residen las reglas críticas de inventario, cumpliendo el requisito de que esas reglas no dependan de widgets ni de la base de datos.
- Las pruebas usan base de datos en memoria (`NativeDatabase.memory()`), no el archivo SQLite real del dispositivo.
