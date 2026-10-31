# Limitaciones conocidas

## Alcance

- La aplicación funciona en un solo dispositivo. No hay sincronización entre
  dispositivos ni usuarios múltiples.
- Está pensada para una tienda y una bodega. No gestiona varias sucursales ni
  transferencias entre almacenes.
- El funcionamiento es sin conexión. No hay integración con servicios en línea.

## Modelo de datos

- El stock se almacena como un valor derivado en `products.stock_actual`. Se
  actualiza en transacciones, pero no se recalcula desde el historial en cada
  consulta.
- No hay borrado físico de productos con movimientos. Los productos se
  desactivan y permanecen en la base de datos.
- Los movimientos no se editan ni se eliminan. Los errores se corrigen con un
  nuevo movimiento de ajuste.

## Reportes

- El valor del inventario se estima como existencias por precio de compra. No
  aplica métodos contables como promedio ponderado o FIFO.
- La exportación genera un archivo CSV en el almacenamiento interno de la
  aplicación. Para abrirlo en otro programa se usa la opción de compartir.

## Códigos

- El QR contiene solo el código único del producto. No incluye existencias ni
  precios, porque cambian con cada movimiento.
- El escaneo depende de la cámara del dispositivo. En dispositivos sin cámara o
  con el permiso denegado, la búsqueda manual cubre la operación.
- La etiqueta se exporta como imagen PNG. No se genera un PDF con varias
  etiquetas por página.

## Concurrencia

- Al ser una aplicación de un solo dispositivo, la concurrencia es limitada. Las
  operaciones que cambian el stock usan transacciones para evitar estados
  inconsistentes.
- El código de error `concurrency_conflict` está definido para futuros usos, pero
  no se genera en el flujo actual de un solo usuario.

## Plataformas

- La compilación y la configuración de Android están verificadas. Otras
  plataformas no se han probado.
- La firma de release usa la clave de depuración. Para publicar en Google Play es
  necesario configurar un keystore propio.

## Fotografías

- La fotografía del producto es opcional y se guarda como ruta local. No se
  redimensiona ni se comprime más allá del ajuste aplicado al seleccionarla.
