# Generación y lectura de códigos

## Generación

Cada producto tiene un código único (`products.code`) que se usa como origen de
dos representaciones:

- **Código de barras Code 128**: se genera a partir del código único.
- **Código QR**: contiene únicamente el código único del producto.

El QR no incluye cantidades ni existencias, porque cambian con cada movimiento.
Codificar datos variables invalidaría la etiqueta al primer movimiento.

La etiqueta se compone en `ProductLabel`
(`lib/features/products/presentation/widgets/product_label.dart`) y muestra:

1. El nombre del producto.
2. La categoría, si está definida.
3. El código de barras Code 128.
4. El código QR.
5. El código único en texto.

Las representaciones se dibujan con el paquete `barcode_widget`.

## Exportación e impresión

La etiqueta se captura como imagen PNG con `RenderRepaintBoundary.toImage` y se
guarda en el directorio de documentos de la aplicación, dentro de la carpeta
`exportaciones`. Desde el detalle del producto se puede:

- **Exportar**: guarda el PNG y muestra la ruta.
- **Compartir**: abre el diálogo del sistema para enviar la imagen a otra
  aplicación o imprimirla.

La captura se hace en
`lib/features/products/presentation/widgets/product_label.dart` y la escritura y
compartición en `lib/core/utils/file_exporter.dart`.

## Unicidad

Antes de guardar un producto, `CreateProductUseCase` comprueba que el código no
esté en uso mediante `ProductRepository.isCodeTaken`. La tabla `products`
refuerza la regla con una restricción `unique` sobre la columna `code`. Si hay
duplicado, el dominio lanza el error `code_duplicated`.

En la edición, `isCodeTaken` acepta un `excludeId` para ignorar el propio
producto.

## Lectura con cámara

El escáner (`lib/features/scanner/presentation/screens/scanner_screen.dart`)
usa el paquete `mobile_scanner` y acepta los formatos:

- `BarcodeFormat.code128`
- `BarcodeFormat.qrCode`

Al detectar un código, la pantalla busca el producto por código único:

- Si existe, muestra sus datos y existencias y ofrece abrir el detalle para
  registrar entrada, salida o ajuste.
- Si no existe, muestra el mensaje `Código no registrado`.

El controlador usa `DetectionSpeed.noDuplicates` y una ventana de tiempo mínima
entre lecturas del mismo valor para no repetir la acción varias veces.

## Búsqueda manual

Cuando la cámara no está disponible o el permiso fue denegado, la pantalla de
escaneo ofrece un campo de búsqueda manual. Acepta código o nombre y lista los
productos que coinciden. Si no hay coincidencias, muestra `Código no
registrado`.

## Permisos y errores de cámara

- El permiso de cámara se declara en `android/app/src/main/AndroidManifest.xml`.
- Si el permiso fue denegado, se muestra un mensaje claro con opción de
  reintentar.
- Si el dispositivo no admite escaneo, se muestra un mensaje y se ofrece la
  búsqueda manual.
- Cualquier otro error de cámara muestra un mensaje y la opción de reintentar.

## Prueba en dispositivo físico

El escaneo debe probarse en un dispositivo físico con cámara. Verifica que:

1. El código de barras Code 128 se lee y abre el producto correcto.
2. El código QR se lee y abre el producto correcto.
3. Un código no registrado muestra el mensaje correspondiente.
4. La búsqueda manual encuentra productos por código y por nombre.
