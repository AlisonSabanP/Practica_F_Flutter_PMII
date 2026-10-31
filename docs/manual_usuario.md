# MANUAL DE USUARIO — INVENTARIO

Sistema de gestión de inventarios con códigos de barras y QR para Android.

> **Versión de la app:** 1.0.0  
> **Versión del manual:** 1.0.0  
> **Plataforma:** Android  
> **Estado:** correspondiente a la versión final entregada de la aplicación

---

## Índice

1. [Instalación y permisos](#1-instalación-y-permisos)
2. [Primera vez y perfil](#2-primera-vez-y-perfil)
3. [Pantalla de inicio](#3-pantalla-de-inicio)
4. [Gestión de productos](#4-gestión-de-productos)
5. [Generación y lectura de etiquetas (códigos de barras y QR)](#5-generación-y-lectura-de-etiquetas)
6. [Entradas, salidas y ajustes de existencias](#6-entradas-salidas-y-ajustes-de-existencias)
7. [Alertas de stock](#7-alertas-de-stock)
8. [Historial de movimientos](#8-historial-de-movimientos)
9. [Exportación del inventario (CSV)](#9-exportación-del-inventario-csv)
10. [Mensajes de error más comunes y cómo resolverlos](#10-mensajes-de-error-más-comunes-y-cómo-resolverlos)
11. [Recomendaciones y buenas prácticas](#11-recomendaciones-y-buenas-prácticas)

---

## 1. Instalación y permisos

### 1.1 Requisitos del dispositivo

- Dispositivo Android (teléfono o tableta) con Android 5.0 (API 21) o superior.
- Almacenamiento interno libre para la base de datos y los archivos exportados.
- Cámara (opcional): necesaria solo para escanear códigos de barras y QR. Si el dispositivo no tiene cámara, se puede usar la búsqueda manual.

### 1.2 Instalación del APK

1. Copia el archivo `Inventario-v1.0.0.apk` al dispositivo Android.
2. Abre el archivo (desde el gestor de archivos, Descargas, etc.).
3. Toca **Instalar**.
4. Si el sistema muestra "Instalar aplicaciones orígenes desconocidos", activa la opción para la aplicación que estás usando (navegador o gestor de archivos) y vuelve a tocar Instalar.
5. Espera a que finalice la instalación y abre la aplicación **INVENTARIO**.

### 1.3 Permisos

Al abrir la app por primera vez, puede solicitar el siguiente permiso:

| Permiso | Para qué se usa | Obligatorio |
|---|---|---|
| Cámara | Escanear códigos de barras y QR de productos | Sí, para el escáner. Si se deniega, aún se puede usar la búsqueda manual. |

Si denegaste el permiso por error, ve a **Ajustes del dispositivo > Aplicaciones > INVENTARIO > Permisos** y activa la Cámara.

> La base de datos y las exportaciones se guardan en el almacenamiento interno de la app, que **no requiere permiso de almacenamiento** en Android.

---

## 2. Primera vez y perfil

### 2.1 Carga automática de datos de demostración

La primera vez que abras la aplicación, se prepara la base de datos local y se cargan automáticamente:

- **3 categorías:** Bebidas, Abarrotes, Aseo y limpieza.
- **15 productos** con códigos, precios, stock mínimo y existencias iniciales.
- Responsable por defecto: `Administrador`; tienda: `Bodega principal`.

Esto ocurre solo una vez. Si reinstalas la app o borras sus datos, se volverán a cargar.

### 2.2 Configurar el perfil (obligatorio antes de mover inventario)

Ve a la pestaña **Perfil** (última icono de la barra inferior).

1. Escribe el **Nombre del responsable** (obligatorio). Este nombre quedará registrado en cada movimiento de inventario que hagas.
2. Escribe el **Nombre de la tienda o bodega** (opcional).
3. Toca **Guardar perfil**.

> Sin un responsable configurado, la app no te dejará registrar entradas, salidas ni ajustes y mostrará el mensaje: *"Configura el responsable en la sección Perfil antes de registrar movimientos."*

### Captura de pantalla esperada (Perfil)

Se muestra una tarjeta con el nombre del responsable y la tienda, dos campos de texto ("Nombre del responsable" y "Nombre de la tienda o bodega") y el botón **Guardar perfil**. Abajo hay una nota que indica que todo se guarda localmente en el dispositivo y funciona sin internet.

---

## 3. Pantalla de inicio

Es la primera pestaña de la barra inferior. Muestra:

- **Resumen del inventario:** productos activos, unidades en stock, valor del inventario y cantidad de alertas de stock.
- **Accesos rápidos:** botones para "Nuevo producto" y "Escanear código".
- **Alertas de stock:** listado de productos cuyo stock está igual o inferior al mínimo. Toca un producto para ir a su detalle.

Toca el icono de actualizar (refresco) en la barra superior para recargar los datos.

### Captura de pantalla esperada (Inicio)

Cuatro tarjetas métricas en cuadrícula, seguida de dos botones de acceso rápido y la sección "Alertas de stock" con productos o un mensaje de que no hay alertas.

---

## 4. Gestión de productos

### 4.1 Ver el catálogo de productos

Ve a la pestaña **Productos**. Verás la lista de productos con su nombre, código, estado de existencias (Disponible / Stock bajo / Sin existencias) y precio de venta.

Puedes:
- **Buscar:** escribe en el campo "Buscar por nombre o código".
- **Filtrar por categoría:** toca una ficha de categoría en la barra horizontal.
- **Solo stock bajo:** activa la opción del menú de filtros.
- **Mostrar inactivos:** toca el icono de ojo en la barra superior.
- **Limpiar filtros:** desde el menú de filtros > "Limpiar filtros".

Toca cualquier producto para abrir su detalle.

### 4.2 Crear un nuevo producto

1. En la pantalla Productos, toca el botón flotante **+ Producto** (o "Nuevo producto" en Inicio).
2. Completa el formulario:
   - **Código único:** identifica al producto (se usa para código de barras y QR). Puedes tocar el icono de renovar para generar uno automáticamente (formato `P` + 10 dígitos).
   - **Nombre:** obligatorio.
   - **Descripción:** opcional.
   - **Categoría:** selecciona una (obligatorio).
   - **Precio de compra** y **Precio de venta:** números (se acepta coma o punto decimal).
   - **Stock mínimo:** entero, a partir del cual se activa la alerta.
   - **Existencias iniciales (opcional):** si ingresas un número, se registrará automáticamente como una entrada de inventario al crear el producto.
   - **Fotografía (opcional):** toca "Elegir" para seleccionar una imagen de la galería.
3. Toca **Crear producto**.

El producto se guarda y se abre su pantalla de detalle. Si hubo un error (código duplicado, precio inválido, etc.), se muestra un mensaje de error.

### 4.3 Editar un producto

1. Abre el detalle de un producto (desde el catálogo o el escáner).
2. Toca el icono **Editar** (lápiz) en la barra superior.
3. Modifica los campos deseados. 
   > El stock actual **no se modifica aquí**: solo cambia al registrar una entrada, salida o ajuste.
4. Toca **Guardar cambios**.

### 4.4 Desactivar o reactivar un producto

Desde el detalle del producto:
- Si está activo: toca **Desactivar producto** y confirma. El producto dejará de aparecer en el catálogo activo y no admitirá movimientos, pero su historial se conserva.
- Si está inactivo: toca **Reactivar producto** para volver a habilitarlo.

---

## 5. Generación y lectura de etiquetas (códigos de barras y QR)

### 5.1 Qué contiene la etiqueta

Cada producto tiene una etiqueta imprimible con:
- Nombre del producto y categoría.
- **Código de barras** (formato Code 128) con el código del producto.
- **Código QR** con el código del producto.
- El código escrito en texto.

> El código de barras y el QR contienen únicamente el **código único del producto** (por ejemplo, `P0000000001`). No contienen precios ni existencias, porque esos cambian con cada movimiento.

### 5.2 Ver y exportar la etiqueta

1. Abre el detalle de un producto.
2. En la sección **Etiqueta**, verás la vista previa con código de barras y QR.
3. Toca **Exportar** para guardar la etiqueta como imagen PNG en la carpeta de exportaciones de la app.
4. Toca **Compartir** para enviar la imagen por correo, mensajería o enviarla a una impresora desde otra aplicación.

### 5.3 Leer un código de barras o QR

1. Ve a la pestaña **Escanear**.
2. Apunta la cámara al código de barras o al QR de un producto (dentro del marco de la pantalla).
3. Si el código está registrado, aparece un resumen "Producto encontrado" con el producto. Toca **Ver detalle y registrar movimiento** para abrir el producto.
4. Si el código no está registrado, se muestra un mensaje de error.

#### Si la cámara no está disponible

Usa la sección **Búsqueda manual** de la misma pantalla:
1. Escribe el código o el nombre del producto.
2. Toca la flecha o presiona Enter.
3. Selecciona el producto de los resultados para ir a su detalle.

---

## 6. Entradas, salidas y ajustes de existencias

Los movimientos se registran desde el detalle de un producto, tocando uno de los tres botones: **Entrada**, **Salida** o **Ajuste**.

### 6.1 Entrada de existencias

1. En el detalle del producto, toca **Entrada**.
2. Ingresa la **cantidad a ingresar** (debe ser mayor que cero).
3. Selecciona el **Motivo** (ej. Compra, Devolución, Existencias iniciales, Transferencia, Otro).
4. El responsable se toma del perfil configurado.
5. Toca **Registrar entrada**.

El stock aumenta y el movimiento queda registrado en el historial.

### 6.2 Salida de existencias

1. Toca **Salida**.
2. Ingresa la **cantidad a retirar** (debe ser mayor que cero y no puede exceder el stock disponible).
3. Selecciona el **Motivo** (ej. Venta, Daño, Pérdida, Vencimiento, Consumo interno, Otro).
4. Toca **Registrar salida**.

> Si intentas retirar más unidades de las que hay, la app rechaza la operación con el mensaje: *"Stock insuficiente: solo hay X unidades disponibles."* y no se registra nada.

### 6.3 Ajuste de existencias (conteo físico)

Usa el ajuste para corregir el stock tras un conteo físico.

1. Toca **Ajuste**.
2. Ingresa la **cantidad contada** (este valor pasará a ser el nuevo stock del producto; puede ser mayor, menor o cero).
3. Selecciona el **Motivo** (ej. Conteo físico, Corrección de error, Merma, Otro).
4. Escribe la **Justificación del ajuste** (obligatoria; ej. "Diferencia detectada en el conteo").
5. Toca **Registrar ajuste**.

> Los movimientos confirmados **no se editan ni se eliminan**. Si hubo un error, registra un nuevo movimiento de ajuste para corregirlo.

### 6.4 Responsable

Todo movimiento queda firmado con el responsable configurado en **Perfil**. Asegúrate de haber guardado el perfil antes de registrar el primer movimiento.

---

## 7. Alertas de stock

La app identifica automáticamente el estado de cada producto:

| Estado | Condición | Color en la etiqueta de stock |
|---|---|---|
| Disponible | `stockActual > minStock` | Verde |
| Stock bajo | `stockActual <= minStock` y mayor que 0 | Naranja |
| Sin existencias | `stockActual <= 0` | Rojo |

Desde **Inicio** o **Historial**, sección "Alertas de stock", verás los productos con stock bajo o agotados. Toca uno para registrar una entrada o ajustar su stock.

---

## 8. Historial de movimientos

Ve a la pestaña **Historial**. Verás:

- El resumen del inventario (misma métrica que Inicio).
- La lista de movimientos recientes con: producto, tipo (entrada/salida/ajuste), motivo, cantidad, stock antes y después, fecha/hora y responsable.
- Indicador visual: verde para entradas (aumento) y rojo para salidas (disminución).

### Filtros del historial

Puedes filtrar los movimientos por:
- **Producto:** selecciona un producto de la lista (o "Todos los productos").
- **Tipo:** entrada, salida, ajuste o "Todos los tipos".
- **Rango de fechas:** toca "Rango de fechas" y selecciona desde y hasta.

Toca el icono de filtro desactivado para limpiar todos los filtros.

---

## 9. Exportación del inventario (CSV)

Desde la pestaña **Historial**, toca el icono de descargar (CSV) en la barra superior.

1. La app genera un archivo CSV con todos los productos (activos e inactivos).
2. El archivo se guarda en la carpeta de exportaciones de la app con nombre `inventario_YYYYMMDD_HHMMSS.csv`.
3. Se abre el menú de compartir de Android para enviarlo o guardarlo.

El CSV incluye las columnas: código, nombre, categoría, descripción, precio de compra, precio de venta, stock actual, stock mínimo, estado de stock, activo y valor de inventario.

---

## 10. Mensajes de error más comunes y cómo resolverlos

| Mensaje de error | Causa probable | Cómo resolverlo |
|---|---|---|
| "El código del producto no es válido." | Código vacío o con caracteres no permitidos. | Usa de 3 a 32 caracteres alfanuméricos, guion o guion bajo. |
| "Ya existe un producto con el código X." | Código duplicado en el catálogo. | Usa otro código o edita el producto existente. |
| "El nombre del producto es obligatorio." | Nombre vacío. | Ingresa un nombre. |
| "Ingresa un número válido." / "Los precios no pueden ser negativos." | Precio no numérico o negativo. | Ingresa un precio válido (acepta coma o punto). |
| "Stock insuficiente: solo hay X unidades disponibles." | Salida mayor que el stock actual. | Reduce la cantidad o registra primero una entrada. |
| "El ajuste requiere una justificación." | Ajuste sin justificación. | Escribe una justificación (ej. "Conteo físico del cierre de mes"). |
| "El motivo es obligatorio." / "El responsable es obligatorio." | Motivo o responsable vacío. | Selecciona un motivo y configura el responsable en Perfil. |
| "Configura el responsable en la sección Perfil antes de registrar movimientos." | Perfil sin nombre de responsable. | Ve a Perfil, escribe el responsable y guarda. |
| "El producto está desactivado y no admite movimientos." | Producto inactivo. | Reactiva el producto desde su detalle. |
| "Permiso de cámara denegado." | Se negó el permiso de cámara. | Actívalo en Ajustes > Aplicaciones > INVENTARIO > Permisos. |
| "Cámara no disponible." | El dispositivo no tiene cámara o falló. | Usa la búsqueda manual por código o nombre. |
| "No se pudo completar la operación." | Error inesperado al guardar/exportar. | Revisa el almacenamiento disponible y reintenta. |

---

## 11. Recomendaciones y buenas prácticas

1. **Configura el perfil primero.** Sin responsable no podrás registrar movimientos.
2. **Usa códigos únicos y claros.** El código es lo que se escanea; evita duplicados.
3. **Registra todo movimiento.** Nunca modifiques el stock "a mano" fuera de una entrada, salida o ajuste; así queda el historial completo.
4. **Los ajustes siempre con justificación.** Anota el motivo real del conteo físico para mantener el inventario auditable.
5. **Exporta periódicamente.** Usa la exportación a CSV para tener respaldos del inventario fuera de la app.
6. **La app funciona sin internet.** Todos los datos están en tu dispositivo; no necesitas conexión para usarla.
7. **Respaldos.** Si vas a desinstalar la app o cambiar de dispositivo, respalda el archivo CSV exportado, ya que la base de datos queda en el dispositivo.

---

## Nota sobre este manual

Este manual se entrega en formato Markdown (`docs/manual_usuario.md`) como documento fuente, listo para convertirse en PDF desde cualquier visor de Markdown, editor de texto con exportación o navegador (opción "Imprimir → Guardar como PDF"). Su contenido corresponde exactamente a la versión final 1.0.0 de la aplicación entregada.
