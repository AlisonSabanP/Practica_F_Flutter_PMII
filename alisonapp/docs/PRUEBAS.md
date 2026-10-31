# Pruebas realizadas

## Herramientas

Las pruebas se ejecutan con `flutter test`. Las pruebas de integración de la
base de datos usan SQLite en memoria mediante `AppDatabase.forTesting`, por lo
que ejercitan el código real de los repositorios y de las transacciones.

```bash
flutter test
```

En Linux, las pruebas que usan la base de datos nativa requieren indicar la
biblioteca de SQLite:

```bash
LD_LIBRARY_PATH=/ruta/a/libsqlite3 flutter test
```

## Resultado

```
42 pruebas, todas correctas
```

## Archivos de prueba

| Archivo | Contenido |
| --- | --- |
| `test/domain/stock_calculator_test.dart` | Reglas puras de entradas, salidas y ajustes. |
| `test/domain/movement_validator_test.dart` | Validación de movimientos y motivos. |
| `test/domain/product_validator_test.dart` | Validaciones de producto. |
| `test/domain/inventory_flow_test.dart` | Flujo completo contra la base de datos real. |

## Evidencia de las reglas de inventario

### Entradas

- Suma la cantidad al stock actual.
- Rechaza cantidad cero con `quantity_not_positive`.
- Rechaza cantidad negativa.

### Salidas

- Descuenta la cantidad del stock actual.
- Permite dejar el stock en cero.
- Rechaza salida superior al stock con `insufficient_stock`.
- Rechaza cantidad cero.

### Ajustes

- Fija el stock en la cantidad contada.
- Permite ajustar a cero con justificación.
- Exige justificación no vacía con `justification_required`.

### Validación de movimientos

- Acepta entradas válidas.
- Rechaza motivo o responsable vacíos.
- Rechaza ajuste sin justificación.

### Flujo de aceptación completo

La prueba `entrada, salida, alerta y ajuste conservan el historial` reproduce el
flujo solicitado sobre la base de datos real:

1. Crea un producto con stock mínimo de 5 unidades.
2. Registra una entrada de 20 unidades y verifica `previousStock = 0` y
   `resultingStock = 20`.
3. Registra una salida de 16 unidades y verifica que quedan 4.
4. Comprueba que el producto queda en alerta de stock bajo.
5. Intenta retirar 5 unidades con solo 4 disponibles y verifica que falla con
   `insufficient_stock`.
6. Confirma que el stock no cambia tras el intento fallido.
7. Registra un ajuste a 3 unidades con justificación y verifica el resultado.
8. Comprueba que el historial tiene los 3 movimientos en orden.

### Transaccionalidad

- `una salida fallida no altera el stock ni deja movimiento`: tras una salida
  inválida, el stock permanece igual y el conteo de movimientos no cambia.
- `guarda las existencias iniciales como movimiento de entrada`: crear un
  producto con existencias iniciales genera un movimiento de entrada con
  `previousStock = 0`.
- `no registra movimiento cuando no hay existencias iniciales`.
- `rechaza un código duplicado`.

### Consultas y reportes

- Filtra el historial por tipo de movimiento.
- Lista los productos con stock igual o inferior al mínimo.
- Filtra el historial por rango de fechas.

### Desactivación

- Un producto con movimientos se desactiva sin borrar su historial.
- El producto desactivado deja de aparecer en el listado activo pero se
  conserva al incluir inactivos.

## Prueba en dispositivo físico

El escaneo de códigos de barras y QR debe probarse en un dispositivo físico con
cámara. La lista de comprobación está en `docs/CODIGOS.md`.

## Verificación estática

```bash
flutter analyze
```

El análisis estático no reporta errores en el código de la aplicación. Los
avisos que aparecen provienen del archivo generado por Drift
(`app_database.g.dart`).
