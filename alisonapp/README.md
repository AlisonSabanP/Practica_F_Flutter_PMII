# INVENTARIO

Aplicación móvil en Flutter y Dart para administrar el inventario de una tienda
o bodega. Permite gestionar productos, generar y leer códigos de barras y QR, y
registrar movimientos de inventario con historial persistente.

El alcance es de un solo dispositivo, una tienda y una bodega, con
funcionamiento sin conexión.

- Repositorio: `inventario`
- Nombre de la aplicación: `INVENTARIO`
- Paquete Dart: `inventario`
- Application ID de Android: `com.inventario.app`

## Características

- Gestión de productos: crear, consultar, editar y desactivar.
- Categorías de productos con filtros.
- Generación de códigos de barras Code 128 y códigos QR por producto.
- Etiqueta imprimible con nombre, código y ambas representaciones.
- Lectura de códigos de barras y QR con la cámara del dispositivo.
- Búsqueda manual por código o nombre cuando la cámara no está disponible.
- Registro de entradas, salidas y ajustes de existencias.
- Historial de movimientos filtrable por producto, tipo y rango de fechas.
- Alertas de stock igual o inferior al mínimo.
- Exportación del inventario a CSV y del listado de movimientos.
- Cálculo del valor del inventario a partir del precio de compra.
- Perfil local con el nombre del responsable por defecto.
- Persistencia local con Drift (SQLite). Los datos sobreviven al cierre de la app.

## Requisitos

- Flutter 3.24 o superior (Dart 3.5 o superior).
- Android SDK con JDK 17 para compilar el APK.
- Un dispositivo o emulador Android con cámara para probar el escaneo.

## Instalación y ejecución

```bash
# 1. Clonar el repositorio
git clone <URL_DEL_REPOSITORIO> inventario
cd inventario

# 2. Instalar dependencias
flutter pub get

# 3. Generar el código de la base de datos (Drift)
dart run build_runner build --delete-conflicting-outputs

# 4. Ejecutar en un dispositivo o emulador conectado
flutter run
```

## Pruebas

```bash
flutter test
```

Las pruebas de integración de la base de datos usan SQLite en memoria. En Linux
puede ser necesario indicar la ruta de la biblioteca nativa:

```bash
LD_LIBRARY_PATH=/ruta/a/libsqlite3 flutter test
```

## Compilación del APK

```bash
# APK de depuración
flutter build apk --debug

# APK de release
flutter build apk --release
```

El archivo se genera en `build/app/outputs/flutter-apk/app-release.apk`.

Para instalar el APK en un dispositivo conectado:

```bash
flutter install --release
# o
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Estructura del proyecto

```
lib/
  core/                 Utilidades compartidas, base de datos y tema
  features/
    products/           Productos, categorías y generación de códigos
    inventory/          Movimientos de inventario y reglas de existencias
    scanner/            Lectura de códigos con la cámara
    reports/            Consultas, historial y exportación
    settings/           Perfil local y datos de demostración
    home/               Navegación y pantalla de inicio
```

Cada feature se organiza en capas `presentation`, `domain` y `data`. Consulta
`docs/ARQUITECTURA.md` para más detalle.

## Documentación

- `docs/ARQUITECTURA.md`: arquitectura feature + domain y estructura de carpetas.
- `docs/MODELO_DE_DATOS.md`: tablas, diccionario de campos y relaciones.
- `docs/CASOS_DE_USO.md`: casos de uso y reglas de negocio.
- `docs/CODIGOS.md`: generación y lectura de códigos de barras y QR.
- `docs/VALIDACIONES_Y_ERRORES.md`: validaciones y manejo de errores.
- `docs/PRUEBAS.md`: pruebas realizadas y evidencias.
- `docs/COMPILACION_APK.md`: compilación del APK para Android.
- `docs/LIMITACIONES.md`: limitaciones conocidas.
- `docs/MANUAL_DE_USUARIO.md`: manual de usuario.

## Datos de demostración

La primera vez que se abre la aplicación se cargan 3 categorías y 15 productos
con sus movimientos de entrada iniciales. También se crea un perfil con el
responsable `Administrador`.
