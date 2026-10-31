# Arquitectura

El proyecto usa Flutter y Dart con una arquitectura **feature + domain**. El
código se organiza por funcionalidad y cada funcionalidad se divide en tres
capas con responsabilidades claras.

## Capas

- **domain**: entidades, casos de uso y contratos de repositorio. Contiene las
  reglas de inventario y no depende de widgets ni de la base de datos.
- **data**: implementa los contratos del dominio y concentra el acceso al
  almacenamiento local (Drift).
- **presentation**: pantallas, widgets y gestión de estado con Riverpod.

El dominio se mantiene puro: no importa `flutter/material.dart` ni `drift`. Las
reglas de negocio viven en servicios y casos de uso del dominio, de modo que se
pueden probar sin UI y sin base de datos.

## Flujo de dependencias

```
presentation  ->  domain  <-  data
```

La capa de presentación consume casos de uso del dominio. La capa de datos
implementa los contratos del dominio. El dominio no conoce a ninguna de las
otras dos. La inyección se resuelve con Riverpod en `lib/core/providers.dart`.

## Estructura de carpetas

```
lib/
  main.dart                     Punto de entrada
  app.dart                      MaterialApp y arranque de la base de datos
  core/
    database/
      app_database.dart         Tablas Drift y apertura de la base de datos
      app_database.g.dart       Código generado por Drift
    error/
      app_failure.dart          Fallo listo para mostrar al usuario
      domain_exception.dart     Excepción de reglas de negocio
      error_codes.dart          Códigos de error estables
    result/
      result.dart               Resultado Success/Failure
    theme/
      app_theme.dart            Tema visual Material 3
    utils/
      code_generator.dart       Generador de códigos únicos
      file_exporter.dart        Escritura y compartición de archivos
      formatters.dart           Formatos de moneda, fecha y número
    widgets/                    Widgets compartidos (tarjetas, estados vacíos)
    providers.dart              Inyección de dependencias con Riverpod
  features/
    products/
      domain/
        entities/               Category, Product, ProductDraft
        repositories/           ProductRepository (contrato)
        services/               ProductValidator
        usecases/               Crear, actualizar, desactivar, buscar
      data/
        product_mapper.dart
        repositories/           DriftProductRepository
      presentation/
        screens/                Listado, formulario y detalle
        widgets/                Etiqueta con códigos, elemento de lista
    inventory/
      domain/
        entities/               Movement, MovementType, MovementFilter, ...
        repositories/           MovementRepository (contrato)
        services/               StockCalculator, MovementValidator
        usecases/               Registrar movimiento, historial, stock bajo
      data/
        movement_mapper.dart
        repositories/           DriftMovementRepository
      presentation/
        screens/                Registro de movimiento
    scanner/
      presentation/
        screens/                Lectura con cámara y búsqueda manual
    reports/
      domain/
        entities/               InventoryReport
        repositories/           ReportRepository (contrato)
        services/               CsvBuilder
        usecases/               Construir reporte, exportar CSV
      data/
        repositories/           DriftReportRepository
      presentation/
        screens/                Historial y reportes
    settings/
      domain/
        entities/               LocalProfile
        repositories/           ProfileRepository, DemoDataRepository
        usecases/               Perfil, datos de demostración
      data/
        demo_data_seeder.dart
        repositories/           DriftProfileRepository
      presentation/
        screens/                Perfil local
    home/
      presentation/
        screens/                Contenedor de navegación e inicio
```

## Gestión de estado

Se usa **Riverpod** en todo el proyecto, sin mezclar enfoques.

- `Provider`: repositorios, casos de uso y utilidades.
- `StreamProvider`: productos, categorías, perfil y alertas de stock, que se
  actualizan en vivo al cambiar la base de datos.
- `FutureProvider`: reporte del inventario y arranque de los datos de
  demostración.
- `NotifierProvider`: filtro activo del historial de movimientos.

Las pantallas observan el estado con `ref.watch` y ejecutan acciones con
`ref.read`, sin lógica de negocio en los widgets.

## Persistencia

La persistencia local usa **Drift** sobre SQLite. La base de datos se abre en
`lib/core/database/app_database.dart` y guarda el archivo `inventario.sqlite` en
el directorio de documentos de la aplicación. Las escrituras que afectan al
stock se ejecutan en transacciones para garantizar atomicidad.

## Por qué feature + domain

- Cada funcionalidad es independiente y localizable.
- Las reglas de inventario se prueban sin UI ni base de datos.
- Cambiar el almacenamiento solo afecta a la capa `data`.
- La interfaz depende de contratos estables del dominio.
