# Compilación del APK para Android

## Requisitos

- Flutter 3.24 o superior.
- Android SDK con `compileSdk` 34.
- JDK 17.
- Variables de entorno `ANDROID_HOME` o `ANDROID_SDK_ROOT` configuradas.

El proyecto ya está configurado:

- `android:label="INVENTARIO"` en `android/app/src/main/AndroidManifest.xml`.
- `applicationId = "com.inventario.app"` y `namespace = "com.inventario.app"` en
  `android/app/build.gradle`.
- Permiso de cámara declarado en el manifiesto.

## Pasos

```bash
# Instalar dependencias
flutter pub get

# Generar el código de la base de datos
dart run build_runner build --delete-conflicting-outputs

# Compilar el APK de release
flutter build apk --release
```

El APK se genera en:

```
build/app/outputs/flutter-apk/app-release.apk
```

## APK de depuración

```bash
flutter build apk --debug
```

El archivo se genera en `build/app/outputs/flutter-apk/app-debug.apk`.

## APK dividido por arquitectura

Para reducir el tamaño, se puede generar un APK por arquitectura:

```bash
flutter build apk --split-per-abi
```

Los archivos se generan por cada ABI (`arm64-v8a`, `armeabi-v7a`, `x86_64`).

## Instalación en un dispositivo

```bash
# Con Flutter
flutter install --release

# Con adb
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Firma

El proyecto usa la firma de depuración para la compilación de release, de modo
que `flutter build apk --release` funciona sin configuración adicional. Para
publicar en Google Play es necesario crear un keystore y configurar la firma de
release en `android/app/build.gradle`.

## Solución de problemas

- **`sdk.dir` no encontrado**: define `ANDROID_HOME` o crea
  `android/local.properties` con `sdk.dir=/ruta/al/android-sdk`.
- **Falta una plataforma del SDK**: instala la plataforma con
  `sdkmanager "platforms;android-34"`.
- **Falta la versión de Java**: usa JDK 17. Otras versiones pueden fallar con
  Gradle.
- **Error de memoria de Gradle**: ajusta `org.gradle.jvmargs` en
  `android/gradle.properties`.
