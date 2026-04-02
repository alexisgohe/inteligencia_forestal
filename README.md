# 📱 Proyecto Inteligencia Forestal: Guía rápida para desarrollo

Este proyecto está construido con **Flutter**.\
Te muestro lo básico para levantarlo y comenzar a editar.

------------------------------------------------------------------------

## 🚀 Requisitos

Antes de empezar, verifica que tu entorno está listo:

``` bash
flutter doctor
```

En caso de tener [X] o [!], preguntale a Chat GTP, la siguiente la puedes dejar pendiente ya que es para aplicaciones en windows:
[!] Visual Studio - develop Windows apps (SQL Server Management Studio 21 21.5.14) 
  [X] Visual Studio is missing necessary components. Please re-run the Visual Studio installer for the "Desktop development with C++" workload, and include these components: 
  MSVC v142 - VS 2019 C++ x64/x86 build tools 
  - If there are multiple build tool versions available, install the latest 
  C++ CMake tools for Windows 
  Windows 10 SDK
------------------------------------------------------------------------

## ▶️ Levantar el proyecto

``` bash
flutter pub get
flutter run
```

Cuando le des flutter run, selecciona el nombre del dispositivo virtualizado que creaste en Android Studio

Listar dispositivos:

``` bash
flutter devices
```

------------------------------------------------------------------------

## 📁 Estructura básica del proyecto

    lib/
     ├─ main.dart
     └─ src/
         ├─ ui/
         ├─ data/
         └─ domain/

------------------------------------------------------------------------

## 🧩 ¿Dónde trabajar?

-   Pantallas → `lib/src/ui/screens/`
-   Widgets → `lib/src/ui/widgets/`
-   Modelos → `lib/src/domain/models/`
-   Servicios → `lib/src/data/`
-   Dependencias instaladas → `pubspec.yaml`

------------------------------------------------------------------------

## 📦 Agregar dependencias

``` bash
flutter pub add nombre_paquete
```

------------------------------------------------------------------------

## 🧪 Hot Reload & Hot Restart

-   Hot Reload → `r`
-   Hot Restart → `R`

------------------------------------------------------------------------

## 🔧 Comandos útiles

  Acción                 Comando
  ---------------------- ---------------------
  Obtener dependencias   `flutter pub get`
  Limpiar                `flutter clean`
  Build Android          `flutter build apk`
  Build iOS              `flutter build ios`
  Ver dispositivos       `flutter devices`
  Formatear              `dart format .`

------------------------------------------------------------------------

## 📱 Compatibilidad y configuración de Android

Esta aplicación está configurada para ejecutarse en una amplia gama de dispositivos Android sin perder soporte moderno.
La compilación usa una configuración estable y recomendada para proyectos Flutter en 2025.

## ✔ Compatibilidad con dispositivos

- Versión mínima soportada: Android 7.0 (API 24)
- Garantiza compatibilidad con más del 95% de los dispositivos activos.
- Ideal para equipos que quieren estabilidad sin limitarse a APIs antiguas.

## ✔ Configuración del proyecto Android

El proyecto utiliza valores fijos (no dependientes de la versión de Flutter) para asegurar un entorno consistente:

Configuración	            Valor
------------------------- ---------------------
minSdkVersion	            24
targetSdkVersion	        34
compileSdkVersion	        36
Java / Kotlin JVM target	17

## ✔ Razones de esta configuración

- minSdk 23: es la versión mínima segura para Flutter y mantiene compatibilidad con la mayoría de teléfonos.
- targetSdk 34: requerido por Google Play en 2024–2025.
- compileSdk 36: versión madura, estable y sin cambios rompientes.
- Java 17: recomendado por Google y utilizado por AGP moderno.

## ✔ Consideraciones para el desarrollo
- Si instalas librerías externas, asegúrate de que soporten minSdk 23.
- Las compilaciones para Android funcionan tanto en emuladores x86/x86_64 como en dispositivos físicos.

------------------------------------------------------------------------