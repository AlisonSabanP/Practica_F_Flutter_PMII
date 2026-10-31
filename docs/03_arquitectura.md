# 03. Arquitectura Feature + Domain

## 1. Visión general

El proyecto organiza el código por **funcionalidades (features)** y, dentro de cada una, separa las responsabilidades en tres capas:

1. **Presentación** — pantallas, widgets y gestión de estado (Riverpod).
2. **Dominio** — entidades, casos de uso y contratos de repositorio (interfaces abstractas). Contiene las reglas de negocio puras.
3. **Datos** — implementaciones de repositorios, mappers y acceso al almacenamiento (Drift/SQLite).

Además, existe una carpeta `core/` con utilidades transversales (base de datos, tema, errores, providers globales, formateadores, generador de códigos, exportador de archivos).

## 2. Estructura de carpetas

```
lib/
├── app.dart                      # Punto de entrada de la app (MaterialApp + bootstrap)
├── core/
│   ├── database/                 # AppDatabase (Drift), tablas, conexión SQLite
│   ├── error/                    # AppFailure, DomainException, ErrorCodes
│   ├── providers.dart            # Providers globales (repositorios, casos de uso, streams)
│   ├── result/                   # Result<T> (sealed: Success / Failure)
│   ├── theme/                    # AppTheme (Material 3)
│   ├── utils/                    # code_generator, file_exporter, app_directories, formatters
│   └── widgets/                  # feedback, empty_state, metric_card
└── features/
    ├── home/                     # Dashboard, resumen y alertas de stock
    │   └── presentation/
    │       └── screens/          # home_screen.dart, home_shell.dart
    ├── products/                 # Catálogo de productos y categorías
    │   ├── domain/
    │   │   ├── entities/         # product.dart, category.dart, product_draft.dart
    │   │   ├── repositories/     # product_repository.dart (contrato)
    │   │   ├── services/         # product_validator.dart (reglas de producto)
    │   │   └── usecases/         # create, update, find, search, deactivate, reactivate
    │   ├── data/
    │   │   ├── repositories/     # drift_product_repository.dart (impl. Drift)
    │   │   └── product_mapper.dart
    │   └── presentation/
    │       ├── screens/          # products_screen, product_form_screen, product_detail_screen
    │       └── widgets/          # product_tile, product_label
    ├── inventory/                # Movimientos de existencias y reglas de stock
    │   ├── domain/
    │   │   ├── entities/         # movement, movement_type, movement_request, stock_change, movement_filter
    │   │   ├── repositories/     # movement_repository.dart (contrato)
    │   │   ├── services/         # stock_calculator.dart, movement_validator.dart (REGLAS DE INVENTARIO)
    │   │   └── usecases/         # register_movement, get_movement_history, get_low_stock_products
    │   ├── data/
    │   │   ├── repositories/     # drift_movement_repository.dart (impl. Drift, transaccional)
    │   │   └── movement_mapper.dart
    │   └── presentation/
    │       └── screens/          # movement_screen.dart
    ├── reports/                  # Historial, métricas y exportación
    │   ├── domain/
    │   │   ├── entities/         # inventory_report.dart
    │   │   ├── repositories/     # report_repository.dart (contrato)
    │   │   ├── usecases/         # build_inventory_report, export_inventory_csv
    │   │   └── services/         # csv_builder.dart
    │   ├── data/
    │   │   └── repositories/     # drift_report_repository.dart
    │   └── presentation/
    │       └── screens/          # history_screen.dart
    ├── scanner/                  # Lectura de códigos de barras y QR
    │   └── presentation/
    │       └── screens/          # scanner_screen.dart
    └── settings/                 # Perfil local y datos de demostración
        ├── domain/
        │   ├── entities/         # local_profile.dart
        │   ├── repositories/     # profile_repository, demo_data_repository (contratos)
        │   └── usecases/         # profile_use_cases, seed_demo_data_use_case
        ├── data/
        │   ├── repositories/     # drift_profile_repository
        │   └── demo_data_seeder.dart (15 productos, 3 categorías)
        └── presentation/
            └── screens/          # profile_screen.dart
```

## 3. Responsabilidades por capa

### Presentación (UI + estado)

- Pantallas (`*.dart` en `presentation/screens/`): construyen la interfaz con Material 3.
- Widgets reutilizables (`presentation/widgets/`): `ProductTile`, `ProductLabel`, `StockBadge`, métricas, estados vacíos, feedback (snackbars).
- Gestión de estado: **Riverpod** (`flutter_riverpod`). Proveedores de tipo `Provider`, `StreamProvider`, `FutureProvider`, `NotifierProvider` y `AutoDisposeFutureProviderFamily`.
- La presentación **no contiene reglas de negocio**: solo llama a casos de uso y muestra `AppFailure`/`DomainException` mediante `showFailureSnackBar`.

### Dominio (reglas de negocio puras)

- **Entidades:** modelos inmutables (`Product`, `Category`, `Movement`, `MovementRequest`, `InventoryReport`, `LocalProfile`, etc.).
- **Casos de uso:** clases con método `call()` que orquestan una operación de negocio (`CreateProductUseCase`, `RegisterMovementUseCase`, `BuildInventoryReportUseCase`, etc.).
- **Contratos de repositorio:** clases `abstract` que definen qué puede hacer la capa de datos (ej. `ProductRepository`, `MovementRepository`, `ReportRepository`).
- **Servicios de reglas:** `StockCalculator` y `MovementValidator` (inventario), `ProductValidator` (productos), `CsvBuilder` (reportes). Son clases puras, sin dependencia de Flutter/Drift/UI.
- **Resultados:** `Result<T>` (`Success`/`Failure`) y `AppFailure` para propagar errores tipificados (`ErrorCodes`).

### Datos (almacenamiento)

- **Repositorios Drift:** implementan los contratos de dominio sobre `AppDatabase` (`DriftProductRepository`, `DriftMovementRepository`, `DriftProfileRepository`, `DriftReportRepository`).
- **Mappers:** convierten filas de Drift (`ProductRow`, `MovementRow`, etc.) en entidades de dominio (`ProductMapper`, `MovementMapper`, `CategoryMapper`).
- **Seedero:** `DemoDataSeeder` carga los datos de demostración (idempotente).
- **Transacciones:** el registro de movimientos y la actualización de stock se ejecutan dentro de una sola transacción de Drift (`_db.transaction`) para garantizar atomicidad.

## 4. Flujo de dependencias

La dependencia siempre va de la capa más externa hacia la más interna (regla de dependencias invertida):

```
Presentación  →  Dominio  →  Datos
     ↓           ↓         ↓
Pantallas     Casos de   Repositorios Drift
+ Riverpod    Uso         + SQLite
+ Widgets     Servicios   + Mappers
              (reglas     + Seedero
               puras)
```

Ejemplo concreto (registro de una salida):

1. `MovementScreen` (presentación) llama a `RegisterMovementUseCase` (dominio) vía Riverpod.
2. `RegisterMovementUseCase` valida con `MovementValidator` y delega a `MovementRepository` (contrato de dominio).
3. `DriftMovementRepository` (datos) ejecuta `StockCalculator.apply` (dominio), registra el movimiento y actualiza el stock en una transacción SQLite, y devuelve el `Movement`.

## 5. Inversión de dependencias en los repositorios

Los contratos de repositorio se definen en el **dominio** (ej. `abstract class ProductRepository`). La capa de **datos** los implementa (`DriftProductRepository implements ProductRepository`). Los proveedores de Riverpod en `core/providers.dart` inyectan la implementación concreta, por lo que el dominio y la presentación nunca dependen de Drift directamente.

Esto permite, por ejemplo, probar las reglas de inventario con una base de datos en memoria (`AppDatabase.forTesting(NativeDatabase.memory())`) sin tocar la UI ni SQLite real.

## 6. Gestión de estado (Riverpod)

| Proveedor | Tipo | Propósito |
|---|---|---|
| `appDatabaseProvider` | `Provider` | Instancia única de `AppDatabase` (se cierra al.dispose) |
| `productRepositoryProvider`, `movementRepositoryProvider`, … | `Provider` | Repositorios Drift sobre la DB |
| `createProductUseCaseProvider`, `registerMovementUseCaseProvider`, … | `Provider` | Casos de uso con su repositorio inyectado |
| `productsProvider`, `allProductsProvider`, `lowStockProvider`, `categoriesProvider` | `StreamProvider` | Listas reactivas de productos/categorías desde SQLite |
| `productByIdProvider`, `productByCodeProvider` | `FutureProvider.family` | Consulta de un producto por id o código |
| `inventoryReportProvider` | `FutureProvider` | Resumen agregado del inventario |
| `movementFilterProvider` | `NotifierProvider` | Filtro del historial (producto, tipo, fechas) |
| `movementHistoryProvider` | `StreamProvider.family` | Historial de movimientos filtrado, reactivo |
| `profileProvider` | `StreamProvider` | Perfil local (responsable, tienda) |
| `bootstrapProvider` | `FutureProvider` | Preparación de DB y datos demo al iniciar |

## 7. Por qué las reglas de inventario están en el dominio

`StockCalculator` (`features/inventory/domain/services/stock_calculator.dart`) y `MovementValidator` son clases Dart puras:

- **No importan `flutter`**, ni widgets, ni contexto de UI.
- **No importan Drift ni SQLite**, ni acceden a la base de datos.
- Reciben valores primitivos (`int`, `MovementType`, `String`) y devuelven resultados o lanzan `DomainException`.

Esto cumple el requisito de que las reglas de inventario no dependan de los widgets ni de la base de datos, y las hace totalmente testeables de forma aislada (véase `docs/08_pruebas.md`).
