# 06. Generación y lectura de códigos de barras y QR

## 1. Generación de etiquetas (pantalla de detalle del producto)

Cada producto tiene una **etiqueta imprimible** (`ProductLabel`) que incluye:

| Elemento | Contenido | Tecnología |
|---|---|---|
| Nombre del producto | `product.name` | Texto |
| Categoría | `product.category?.name` | Texto |
| Código de barras | `product.code` | Code 128 (`barcode_widget`) |
| QR | `product.code` | QR (`barcode_widget`, corrección de nivel medio) |
| Código legible | `product.code` | Texto debajo del QR |

### Contenido codificado

- **El código de barras y el QR codifican exclusivamente el código único del producto** (ej. `P0000000001`).
- **No se codifican cantidades, precios ni existencias**, porque estos valores cambian con cada movimiento de inventario. La etiqueta sirve únicamente para identificar el producto inequívocamente al escanearlo.

### Exportación y uso de la etiqueta

Desde `ProductDetailScreen` el usuario puede:

1. **Exportar:** renderiza la etiqueta a PNG (`captureBoundary`, pixelRatio 3) y la guarda en la carpeta `exportaciones/` del almacenamiento interno de la app.
2. **Compartir:** guarda el PNG y lo comparte mediante el sistema de compartir de Android (`share_plus`), para enviarlo por correo, mensajería o enviarlo a una impresora.

El nombre del archivo es `etiqueta_<codigo>.png`.

## 2. Lectura de códigos (pantalla Escáner)

`ScannerScreen` utiliza el paquete **mobile_scanner** (versión ^6.0.11).

### Configuración del escáner

```dart
MobileScannerController(
  autoStart: widget.active,
  detectionSpeed: DetectionSpeed.noDuplicates,
  formats: const <BarcodeFormat>[
    BarcodeFormat.code128,
    BarcodeFormat.qrCode,
  ],
)
```

- **Formatos soportados:** Code 128 (códigos de barras generados por la app) y QR Code.
- **Detección:** `noDuplicates` evita lecturas repetidas del mismo código en fracciones de segundo (debounce de 2 segundos).
- **Linterna:** botón para activar/desactivar el flash.
- **Cámara activa solo en la pestaña seleccionada:** `HomeShell` usa un `IndexedStack`; el scanner recibe `active: _index == 2` para iniciar/detener la cámara al cambiar de pestaña y no consumir recursos en segundo plano.

### Flujo de lectura

```
Cámara detecta código de barras/QR
      ↓
_onDetect(BarcodeCapture) → extrae rawValue
      ↓
Debounce (2 s) para evitar duplicados
      ↓
_resolveCode(raw) → findProductByCodeUseCase(code)
      ↓
Producto encontrado → bottom sheet con ProductTile + botón "Ver detalle"
Producto no encontrado → snackbar de error "Código no registrado: X"
Error de lectura → snackbar con el mensaje del exception
```

### Búsqueda manual (respaldo)

Si la cámara no está disponible o el usuario prefiere no usarla, el escáner incluye un campo de **búsqueda manual**:

- Campo de texto con etiqueta "Código o nombre del producto".
- Al enviar, filtra la lista de todos los productos (`allProductsProvider`) por código o nombre.
- Cada resultado es un `ProductTile` que navega al detalle del producto.

## 3. Permisos de cámara

### Declaración en `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature
    android:name="android.hardware.camera"
    android:required="false" />
<uses-feature
    android:name="android.hardware.camera.autofocus"
    android:required="false" />
```

- `CAMERA` es obligatorio para el escáner, pero se declara como `required="false"` para permitir instalar y usar la app en dispositivos sin cámara (la búsqueda manual queda como alternativa).
- `mobile_scanner` gestiona el permiso de cámara en tiempo de ejecución en Android.

### Manejo de estados de la cámara

El escáner muestra estados específicos según el error de `mobile_scanner`:

| Estado | Mensaje al usuario | Acción sugerida |
|---|---|---|
| Cámara iniciada correctamente | Vista de cámara con marco de escaneo | Apuntar al código de barras o QR |
| `permissionDenied` | "Permiso de cámara denegado" | Habilitar el permiso en Ajustes del sistema y reintentar |
| `unsupported` / cámara no disponible | "Cámara no disponible" | Usar la búsqueda manual por código o nombre |
| Otro error | "No se pudo iniciar la cámara" | Reintentar o usar búsqueda manual |

Cada estado incluye un botón **Reintentar** que reinicia el controlador de la cámara.

## 4. Consideraciones

- La lectura requiere iluminación adecuada y el código enfocado dentro del marco de la interfaz.
- Los códigos generados por la app (Code 128) son legibles por el escáner de la misma app y por la mayoría de lectores de códigos de barras estándar.
- El QR admite corrección de errores de nivel medio, lo que permite leerlo incluso si la etiqueta está ligeramente dañada o impresa a baja resolución.
