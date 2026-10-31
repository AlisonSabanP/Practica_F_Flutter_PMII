# INVENTARIO — Sistema de Gestión de Inventarios con Códigos de Barras y QR

Aplicación móvil para Android desarrollada en **Flutter** que permite gestionar productos, categorías, códigos de barras/QR y movimientos de inventario (entradas, salidas y ajustes) de forma totalmente local y sin conexión a internet.

> **Versión:** 1.0.0  
> **Plataforma:** Android (APK de release)  
> **Arquitectura:** Feature + Domain  
> **Estado:** Proyecto completo y probado

---

## 📦 Entregables

| Entregable | Ruta | Descripción |
|---|---|---|
| **APK funcional** | `entregables/Inventario-v1.0.0.apk` | Instalador de release para Android (~76 MB, firmado con clave de debug para pruebas). |
| **README (este archivo)** | `README.md` | Punto de entrada con enlaces a toda la documentación. |
| **Documentación técnica** | `docs/*.md` | Arquitectura, modelo de datos, funcionalidades, códigos de barras/QR, validaciones, pruebas y compilación. |
| **Manual de usuario** | `docs/manual_usuario.md` | Instrucciones, permisos, gestión de productos, etiquetas, movimientos, alertas, historial y exportación (con pasos y capturas de pantalla descritas). Exportable a PDF. |

---

## 🚀 Inicio rápido

1. **Instalar el APK:** Copia `entregables/Inventario-v1.0.0.apk` al dispositivo Android e instálalo (habilita "Orígenes desconocidos" si se solicita).
2. **Permisos:** Concede el permiso de **Cámara** cuando la app lo pida (necesario para escanear códigos de barras y QR).
3. **Perfil:** En la pestaña **Perfil**, configura el nombre del responsable y la tienda/bodega antes de registrar movimientos.
4. **Datos de demostración:** La app carga automáticamente **3 categorías y 15 productos** con existencias iniciales la primera vez que se abre.
5. **Usar:** Desde **Inicio** puedes ver el resumen, alertas de stock y accesos rápidos (nuevo producto, escanear).

---

## 📚 Documentación técnica (en `docs/`)

Cada documento profundiza un aspecto del sistema:

| Documento | Contenido |
|---|---|
| [`docs/01_objetivo_alcance.md`](docs/01_objetivo_alcance.md) | Objetivo, alcance, requisitos y reglas de negocio. |
| [`docs/02_instalacion_ejecucion.md`](docs/02_instalacion_ejecucion.md) | Instalación, configuración, dependencias y ejecución. |
| [`docs/03_arquitectura.md`](docs/03_arquitectura.md) | Arquitectura feature + domain, estructura de carpetas, responsabilidades y flujo de dependencias. |
| [`docs/04_modelo_datos.md`](docs/04_modelo_datos.md) | Modelo de datos, diccionario de campos, relaciones y persistencia (SQLite/Drift). |
| [`docs/05_funcionalidades_casos_uso.md`](docs/05_funcionalidades_casos_uso.md) | Funcionalidades, casos de uso, gestión de estado (Riverpod) y flujo de información. |
| [`docs/06_codigos_barras_qr.md`](docs/06_codigos_barras_qr.md) | Generación y lectura de códigos de barras y QR, contenido codificado y permisos de cámara. |
| [`docs/07_validaciones_errores.md`](docs/07_validaciones_errores.md) | Validaciones, manejo de errores y consistencia de los movimientos. |
| [`docs/08_pruebas.md`](docs/08_pruebas.md) | Pruebas realizadas, pasos de reproducción, resultados y evidencias de reglas de inventario. |
| [`docs/09_compilacion_apk.md`](docs/09_compilacion_apk.md) | Compilación del APK, limitaciones conocidas y mantenimiento. |

---

## 🧪 Pruebas de reglas de inventario

Todas las reglas de dominio (stock, salidas insuficientes, ajustes con justificación, atomicidad, códigos duplicados, productos desactivados) están cubiertas por **42 pruebas unitarias** en `alisonapp/test/domain/`:

```
flutter test test/domain/   →   42 tests, todos pasan
flutter test test/widget_test.dart → 2 tests, todos pasan
```

Véase `docs/08_pruebas.md` para la evidencia detallada.

---

## 🏗️ Arquitectura destacada

El código sigue estrictamente la arquitectura **Feature + Domain**:

```
lib/
├── core/                     # Utilidades, tema, DB, errores, providers globales
└── features/
    ├── home/                 # Dashboard, resumen y alertas
    ├── products/             # Catálogo de productos y categorías
    ├── inventory/            # Movimientos (entrada/salida/ajuste) y reglas de stock
    ├── scanner/              # Lectura de códigos de barras y QR con cámara
    ├── reports/              # Historial, métricas y exportación CSV
    └── settings/             # Perfil local y datos de demostración
```

Cada feature separa **presentación** (pantallas/widgets + Riverpod), **dominio** (entidades, casos de uso, contratos de repositorio, reglas de negocio) y **datos** (repositorios Drift, mappers, acceso a SQLite). Las reglas de inventario viven exclusivamente en el dominio (`StockCalculator`, `MovementValidator`) y no dependen de widgets ni de la base de datos.

---

## 📱 Capturas del sistema (manual de usuario)

El manual de usuario (`docs/manual_usuario.md`) incluye instrucciones paso a paso y descripciones de capturas de pantalla para cada pantalla principal: Inicio, Productos, Escáner, Historial/Reportes y Perfil.

---

## ⚠️ Notas de esta entrega

- El APK está firmado con la **clave de debug** de Flutter (válido para pruebas e instalación en dispositivos Android; no apto para publicación en Play Store sin re-firmar con clave de release).
- Para compilar el APK en otro entorno se requieren **Flutter SDK**, **Android SDK** y un **JDK compatible con Gradle** (véase `docs/09_compilacion_apk.md`).
- La base de datos es **SQLite local** (`inventario.sqlite`) en el directorio de documentos de la app; no requiere servidor ni cuenta de usuario.

---

Desarrollado con Flutter + Riverpod + Drift (SQLite) + mobile_scanner + barcode_widget.
