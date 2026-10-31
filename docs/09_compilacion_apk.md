# 09. Compilación del APK, limitaciones conocidas y mantenimiento

## 1. Compilación del APK de release

El APK funcional ya fue compilado y se entrega en:

```
entregables/Inventario-v1.0.0.apk   (~76 MB, Android release)
```

### Comando de compilación

Desde `alisonapp/`:

```bash
flutter pub get
flutter pub run build_runner build        # genera app_database.g.dart (Drift)
flutter build apk --release
```

El resultado se escribe en:

```
build/app/outputs/flutter-apk/app-release.apk
```

### Firma

El APK está firmado con la **clave de debug** de Flutter (`signingConfig = signingConfigs.debug` en `android/app/build.gradle`). Es válido para instalar y probar en dispositivos Android, pero **no es apto para publicar en Google Play Store**. Para publicación, se debe configurar una firma de release (keystore propio) en `android/app/build.gradle`.

### Versión

- `version`: 1.0.0+1 (pubspec.yaml)
- `applicationId`: `com.inventario.app`
- `minSdkVersion`: definido por Flutter (Android 5.0+)
- `targetSdk`: definido por Flutter
- `compileSdk`: 36

## 2. Ajustes de entorno realizados para esta compilación

En el entorno de compilación de esta entrega se aplicaron dos ajustes de configuración de Android (no afectan la lógica de la app):

1. **Gradle wrapper:** actualizado de `gradle-8.14.3` a `gradle-9.2.1` en `android/gradle/wrapper/gradle-wrapper.properties`, para que sea compatible con el JDK 25 provisto por el Flutter SDK instalado (Gradle 8.14.3 no soporta Java 25).
2. **NDK:** `ndkVersion` cambiado de `27.0.12077973` (no disponible en el SDK local) a `28.2.13676358` (NDK r28c instalado) en `android/app/build.gradle`.
3. Se eliminó la sobreescritura `org.gradle.java.home` que apuntaba a un JDK 21 no instalado.

Estos cambios son específicos del entorno de compilación y se documentan aquí para que cualquier recompilación en otro entorno los tenga en cuenta. En un entorno con JDK 17/21 y Gradle 8.x compatibles, los valores originales pueden restaurarse.

## 3. Limitaciones conocidas

| Área | Limitación | Mitigación / nota |
|---|---|---|
| Firma | APK firmado con clave de debug | No publicar en Play Store sin re-firmar con clave de release |
| Plataforma | Alcance y pruebas centrados en Android | iOS y Web no son objetivo de esta entrega |
| Usuarios | Un responsable por dispositivo, sin autenticación multiusuario | Suficiente para una bodega/tienda pequeña con un responsable |
| Cámara | El escáner requiere cámara y buen enfoque | Si no hay cámara, se usa la búsqueda manual por código/nombre |
| Almacenamiento | Base de datos SQLite local en el dispositivo | No hay sincronización en la nube; respaldar el archivo `inventario.sqlite` si se desea conservar datos al desinstalar |
| Impresión | No hay impresión directa a impresora | Las etiquetas se exportan como PNG y se comparten (el usuario puede imprimir desde otra app) |
| NDK/Gradle | Requiere Gradle compatible con el JDK disponible | Véase ajustes de entorno en §2 |

## 4. Mantenimiento

### Generar código de Drift tras cambios de esquema

Cada vez que se modifique `lib/core/database/app_database.dart` (tablas, columnas), regenerar:

```bash
flutter pub run build_runner build
```

### Actualizar dependencias

```bash
flutter pub upgrade
flutter pub outdated
```

### Ejecutar análisis estático

```bash
flutter analyze
```

### Ejecutar pruebas antes de entregar

```bash
flutter test
```

### Estructura que no debe romperse

Para preservar la arquitectura feature + domain obligatoria:

- Las reglas de negocio (inventario, productos) deben seguir viviendo en `features/<feature>/domain/` y no en widgets ni en repositorios Drift.
- Los contratos de repositorio (`abstract class ...Repository`) deben definirse en `domain/repositories/`.
- Las implementaciones Drift van en `data/repositories/`.
- La presentación solo consume casos de uso vía Riverpod y muestra errores con `showFailureSnackBar`.

## 5. Cómo instalar el APK entregado

1. Copiar `entregables/Inventario-v1.0.0.apk` al dispositivo Android.
2. Abrir el archivo y aceptar la instalación (permitir "orígenes desconocidos" si se solicita).
3. Conceder el permiso de **Cámara** cuando la app lo pida.
4. Configurar el responsable en **Perfil** antes de registrar movimientos.
5. Los datos de demostración (3 categorías, 15 productos) se cargan automáticamente la primera vez.
