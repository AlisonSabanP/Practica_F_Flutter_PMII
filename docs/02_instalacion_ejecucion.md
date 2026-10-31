# 02. Instalación, configuración, dependencias y ejecución

## 1. Instalación de la aplicación (usuario final)

### Requisitos del dispositivo

- Android 5.0 (API 21) o superior (minSdk definido por Flutter).
- Permiso de **Cámara** (para escanear códigos de barras y QR).
- Almacenamiento interno disponible para la base de datos y las exportaciones CSV/etiquetas.

### Pasos

1. Copia el archivo `entregables/Inventario-v1.0.0.apk` al dispositivo Android.
2. Abre el archivo y toca **Instalar**.
3. Si el sistema pide confirmación de "Instalar aplicaciones orígenes desconocidos", permítelo para el navegador/gestor de archivos usado.
4. Al abrir la app por primera vez, concede el permiso de **Cámara** cuando se solicite.
5. La app prepara la base de datos y carga los datos de demostración automáticamente (pantalla de carga).
6. En la pestaña **Perfil**, configura el nombre del responsable (obligatorio para registrar movimientos).

## 2. Configuración inicial dentro de la app

Desde la pestaña **Perfil**:

- **Nombre del responsable:** obligatorio. Se usa como responsable en cada movimiento registrado.
- **Nombre de la tienda o bodega:** opcional, se muestra en el perfil.

Sin un responsable configurado, la app impide registrar movimientos y muestra un mensaje al respecto.

## 3. Ejecución en modo desarrollo (programador)

### Prerrequisitos

| Herramienta | Versión usada | Notas |
|---|---|---|
| Flutter SDK | 3.47.9 (channel stable) | `flutter --version` |
| Dart | 3.13.7 | Incluido en Flutter |
| Android SDK | compileSdk 36 | Con build-tools y NDK |
| JDK | 25.0.3 (proveniente de Flutter) | Gradle 9.2.1 usado para compatibilidad |
| Gradle | 9.2.1 | Wrapper actualizado para JDK 25 |

### Pasos

```bash
# 1. Entrar al proyecto Flutter
cd alisonapp

# 2. Obtener dependencias
flutter pub get

# 3. Generar código de Drift (base de datos)
flutter pub run build_runner build

# 4. Ejecutar pruebas de dominio
flutter test test/domain/

# 5. Ejecutar la app en emulador o dispositivo
flutter run

# 6. Compilar APK de release
flutter build apk --release
```

> **Nota de entorno:** En este equipo se actualizó el wrapper de Gradle de `8.14.3` a `9.2.1` y el `ndkVersion` de `27.0.12077973` a `28.2.13676358` (NDK instalado) para que la compilación funcione con el JDK 25 provisto por Flutter. Véase `docs/09_compilacion_apk.md`.

### Generación de código de Drift

La base de datos usa Drift, que requiere generar `app_database.g.dart`:

```bash
flutter pub run build_runner build
```

Volver a ejecutar este comando cada vez que se modifique `app_database.dart`.

## 4. Dependencias principales (`pubspec.yaml`)

### Producción

| Paquete | Versión | Uso |
|---|---|---|
| flutter | SDK | Framework UI |
| flutter_riverpod | ^2.6.1 | Gestión de estado e inyección de dependencias |
| drift | 2.20.3 | Base de datos SQLite (Dart) |
| sqlite3_flutter_libs | ^0.5.42 | Motor SQLite nativo para Flutter |
| path_provider | ^2.1.5 | Directorio de documentos de la app |
| path | ^1.9.0 | Manipulación de rutas de archivo |
| barcode_widget | ^2.0.4 | Generación de códigos de barras y QR en etiquetas |
| mobile_scanner | ^6.0.11 | Lectura de códigos de barras/QR con la cámara |
| csv | ^6.0.0 | Construcción de archivos CSV |
| share_plus | ^10.1.4 | Compartir archivos (CSV, etiquetas PNG) |
| image_picker | ^1.1.2 | Seleccionar foto del producto desde la galería |
| intl | ^0.20.2 | Formateo de fechas, dinero y enteros |

### Desarrollo

| Paquete | Versión | Uso |
|---|---|---|
| flutter_test | SDK | Pruebas unitarias y de widgets |
| flutter_lints | ^4.0.0 | Reglas de lint recomendadas |
| drift_dev | 2.20.3 | Generación de código de Drift |
| build_runner | ^2.4.13 | Ejecutor de generación de código |

## 5. Permisos de Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

- `CAMERA`: obligatorio para el escáner. Declaredo como `required="false"` para permitir usar la app sin cámara (búsqueda manual).
- El almacenamiento interno de la app (base de datos y carpeta `exportaciones`) **no requiere permisos de almacenamiento** en Android.
- `share_plus` usa el sistema de compartir de Android sin permisos adicionales.

## 6. Ejecución y primera vez

Al iniciar, la pantalla de **bootstrap** (`_BootstrapGate`):

1. Abre la base de datos SQLite local.
2. Ejecuta `SeedDemoDataUseCase`, que carga categorías, productos y movimientos iniciales solo si la base está vacía (idempotente).
3. Una vez listo, muestra el `HomeShell` con las pestañas: Inicio, Productos, Escáner, Historial y Perfil.

Si falla la preparación del almacenamiento, se muestra un estado vacío con botón **Reintentar**.

## 7. Estructura de ejecución clave

```
main.dart (ProviderScope + InventarioApp)
  └── _BootstrapGate (prepara DB + datos demo)
        └── HomeShell (NavigationBar con 5 pestañas)
              ├── HomeScreen        → resumen, alertas, accesos rápidos
              ├── ProductsScreen    → catálogo con búsqueda/filtros
              ├── ScannerScreen     → escáner + búsqueda manual
              ├── HistoryScreen     → historial + exportación CSV
              └── ProfileScreen     → responsable y tienda
```

Cada caso de uso se provee mediante `Riverpod` en `core/providers.dart`, inyectando los repositorios Drift sobre `AppDatabase`.
