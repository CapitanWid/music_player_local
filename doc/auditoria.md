# Auditoría Técnica y Diagnóstico de Arquitectura
**Proyecto:** Lalo Music Player (`lalo_music_player`)  
**Fecha:** 26 de Noviembre de 2026  
**Entorno:** Flutter / Android (con proyección multiplataforma)

---

## 1. Resumen Ejecutivo y Stack Tecnológico

El proyecto es un reproductor de audio local fuera de línea (offline) desarrollado en Flutter. Aunque el código base tiene soporte para plataformas cruzadas (Android, iOS, Windows, Linux, macOS, Web), la implementación actual está fuertemente acoplada a convenciones del sistema de archivos de Android.

* **SDK Dart/Flutter:** Dart `^3.9.2` / Flutter 3.x
* **Motor de reproducción de audio:** `just_audio: ^0.10.5`
* **Soporte de audio en segundo plano:** `just_audio_background: ^0.0.1-beta.17`
* **Lector de metadatos de audio (ID3/Tags):** `audiotags: ^1.4.5`
* **Gestión de permisos y directorios:** `permission_handler: ^12.0.1`, `path_provider: ^2.1.5`
* **Persistencia actual:** Serialización manual a archivos `.json` en almacenamiento local (`path_provider`).

---

## 2. Inventario de Pantallas y Componentes

El proyecto se compone de 7 pantallas principales y 1 widget persistente de reproducción:

| Componente / Archivo | Tipo | Responsabilidad / Descripción |
| :--- | :--- | :--- |
| **`MyHomePage`** (`lib/main.dart`) | Pantalla Principal | Menú hub con botones redondeados hacia las 4 secciones principales y el reproductor anclado en `bottomNavigationBar`. |
| **`ScreenLocalExplorer`** (`lib/screens/screen_local_explorer.dart`) | Pantalla | Solicita permisos de almacenamiento y busca archivos con extensiones `.mp3`, `.m4a`, `.wav`, `.aac`, `.flac` en el almacenamiento local para indexarlos en `biblioteca_local.json`. |
| **`ScreenLocalLibrary`** (`lib/screens/screen_local_library.dart`) | Pantalla | Lee `biblioteca_local.json`, extrae metadatos con `audiotags` (título, artista, duración) y permite reproducir pistas cargando la lista completa en cola. |
| **`ScreenLocalFavoritos`** (`lib/screens/screen_local_favoritos.dart`) | Pantalla | Lee y muestra canciones favoritas desde `favoritos.json`. Permite marcar/desmarcar y reproducir canciones. |
| **`ScreenLocalPlaylists`** (`lib/screens/screen_local_playlists.dart`) | Pantalla | Lista de listas de reproducción guardadas en `playlists.json`. Permite crear nuevas playlists mediante un diálogo modal. |
| **`ScreenPlaylistDetail`** (`lib/screens/screen_playlist_detail.dart`) | Pantalla | Detalle de las canciones asignadas a una lista seleccionada y acceso para añadir canciones existentes. |
| **`ScreenLocalLibraryAddToPlaylist`** (`lib/screens/screen_local_library_add_to_playlist.dart`) | Pantalla | Lista de selección directa de canciones recibidas por parámetro para asociarlas a una playlist. |
| **`ScreenSelectFromLibrary`** (`lib/screens/screen_select_from_library.dart`) | Pantalla / Modal | Selector de canciones con metadata que retorna el elemento seleccionado con `Navigator.pop(context, cancion)`. |
| **`AudioPlayerWidget`** (`lib/widgets/audio_player_widget.dart`) | Widget Reutilizable | Barra flotante de control de audio: información de pista, barra de progreso lineal, tiempos transcurrido/total, botón de favoritos y controles de reproducción (anterior, play/pause, siguiente). |

---

## 3. Funcionalidades Disponibles

- **Explorador y detección de pistas locales:** Filtrado por extensiones de audio comunes.
- **Extracción de metadatos:** Lectura de títulos, artistas y duración mediante etiquetas ID3 con `audiotags`.
- **Reproducción secuencial en cola:** Posibilidad de cargar un listado y reproducir pistas con navegación anterior/siguiente.
- **Gestión de Favoritos:** Persistencia de rutas favoritas en disco y reactividad en el botón de corazón del reproductor.
- **Creación y gestión de Playlists:** Creación de listas personalizadas con persistencia local en JSON.
- **Mini-reproductor interactivo:** Widget persistente con actualización visual en tiempo real de reproducción y estado del reproductor.

---

## 4. Análisis de Arquitectura

### Fortalezas
1. **Patrón Singleton:** `AudioPlayerService` centraliza la instancia de `AudioPlayer`, asegurando que no existan múltiples instancias reproduciendo audio de forma desincronizada.
2. **Reactividad Ligera:** Empleo de `ValueNotifier` y `ValueListenableBuilder` para cambios de estado puntuales (`isPlaying`, `currentSong`, `playlists`), evitando añadir sobrecarga de librerías de estado complejas para una app pequeña.
3. **Estructuración básica:** Separación visible entre modelo (`lib/model/`), servicios (`lib/services/`), pantallas (`lib/screens/`) y widgets (`lib/widgets/`).

### Debilidades
1. **Estado desarticulado entre UI y Servicio:** `ScreenLocalLibrary` administra su propia lista de canciones en un `State` local sin pasársela a `AudioPlayerService.songs`. Esto provoca que el servicio no disponga de la biblioteca para resolver las playlists.
2. **Persistencia frágil en JSON planos:** Escribir y leer archivos de texto completos (`jsonEncode`/`jsonDecode`) para operaciones CRUD no es escalable ni tolerante a fallos de escritura en discos de dispositivos móviles.
3. **Efectos secundarios dentro del método de renderizado (`build`):** La transición automática a la siguiente canción al finalizar una pista se está ejecutando dentro del `StreamBuilder` visual de `audio_player_widget.dart`.
4. **Acoplamiento exclusivo a Android:** Rutas del sistema de ficheros absolutas hardcodeadas impiden la ejecución en plataformas de escritorio o iOS.

### Diagnóstico y Decisión de Arquitectura
* **Diagnóstico:** La arquitectura actual basada en **Singleton rudimentario y Vistas Inteligentes ("Smart UI") no es la adecuada** para un producto escalable y mantenible. El acoplamiento entre la interfaz gráfica y la lógica de acceso a datos/archivos genera inconsistencias de estado (como el bug de playlists) e imposibilita la creación de pruebas unitarias.
* **Decisión de migración:** Se adoptará formalmente la arquitectura **MVVM (Model-View-ViewModel)** con una capa intermedia de Repositorios. Esto garantizará:
  * Vistas declarativas y desacopladas (UI pasiva).
  * ViewModels como intermediarios reactivos para la gestión del estado.
  * Repositorios y Servicios independientes que abstraigan la persistencia y la reproducción de audio.

---

## 5. Cuadro de Hallazgos y Alternativas de Solución

A continuación se presenta la matriz técnica de cada hallazgo detectado junto a sus alternativas de resolución:

| # | Hallazgo / Problema Detectado | Alternativa de Solución 1 | Alternativa de Solución 2 |
| :-: | :--- | :--- | :--- |
| **1** | **`just_audio_background` no configurado:** Falta llamada obligatoria `await JustAudioBackground.init(...)` en `main()`, faltan servicios y permisos (`FOREGROUND_SERVICE`, `WAKE_LOCK`) en `AndroidManifest.xml`, y `MainActivity` no extiende `AudioServiceActivity`. Provoca crash o falla de segundo plano al apagar la pantalla. | Configurar `JustAudioBackground.init()` en `main.dart`, registrar el servicio y receptor en `AndroidManifest.xml` con permisos de Android 14 (`FOREGROUND_SERVICE_MEDIA_PLAYBACK`), y heredar de `AudioServiceActivity` en `MainActivity.kt`. | Descartar `just_audio_background` y utilizar únicamente `just_audio` en primer plano (si no se requiere reproducción con la pantalla apagada o notificación multimedia). |
| **2** | **Desconexión de datos en Playlists:** `AudioPlayerService.songs` nunca es poblado por `ScreenLocalLibrary`. Al reiniciar la app, `_cargarPlaylists()` busca canciones en una lista vacía, borrando de memoria las canciones de las listas. Además, la pantalla para agregar a playlist se abre vacía. | Centralizar la carga de canciones en `AudioPlayerService.cargarBiblioteca()` para que el servicio sea la única fuente de verdad y alimente `songs.value`. | Pasar la lista de canciones en memoria explícitamente como argumento de navegación entre pantallas y actualizar `audioService.setSongs(lista)` al terminar el escaneo. |
| **3** | **Falta de acción de reproducción en Detalle de Playlist:** En `ScreenPlaylistDetail`, los elementos `ListTile` que listan las canciones no implementan el callback `onTap`, imposibilitando reproducir música desde una lista. | Implementar el evento `onTap` en el `ListTile` invocando `audioService.cargarCola(playlist.songs)` y `audioService.reproducirEn(index)`. | - |
| **4** | **Escaneo de archivos dependiente de ruta fija `/storage/emulated/0/`:** Incompatible con Android 11+ (Scoped Storage / API 30+), bloqueado en versiones modernas sin permisos especiales y causa fallo en iOS, Windows, Linux y Mac. | Reemplazar el escaneo directo de carpetas por el plugin `on_audio_query` (que consulta directamente el `MediaStore` nativo de Android/iOS de forma estándar y rápida). | Implementar un selector de carpetas multiplataforma (`file_picker`) que permita al usuario seleccionar qué directorio de su equipo o móvil desea indexar. |
| **5** | **Bloqueo del hilo de interfaz durante el escaneo:** `dir.listSync()` se ejecuta síncronamente en el hilo principal de Flutter, generando congelamiento visual (lag/ANR) si el usuario tiene miles de archivos. | Ejecutar la búsqueda de archivos en un Isolate secundario en segundo plano utilizando `compute()` o `Isolate.run()`. | Utilizar la API asíncrona de Dart `dir.list(recursive: true)` procesando los elementos mediante Streams sin bloquear el Event Loop. |
| **6** | **Barra de reproducción sin posibilidad de adelantar/retroceder (Seek):** Se utiliza `LinearProgressIndicator` (de solo visualización), por lo que el usuario no puede saltar a un punto específico de la canción. | Reemplazar el `LinearProgressIndicator` por un widget `Slider` conectado al evento `onChanged` con `audioService.player.seek(Duration(...))`. | - |
| **7** | **Lógica de negocio ejecutada dentro del `build` de la UI:** La detección de fin de pista (`ProcessingState.completed`) para llamar a `siguiente()` está dentro del `builder` de un `StreamBuilder` en `AudioPlayerWidget`, lo que puede disparar saltos dobles o excepciones durante el render. | Mover el listener del stream `player.playerStateStream` directamente dentro del constructor de `AudioPlayerService`, reaccionando a nivel de servicio. | - |
| **8** | **Persistencia artesanal en archivos JSON planos:** `biblioteca_local.json`, `playlists.json` y `favoritos.json` se leen y reescriben completamente en cada acción, sin soporte para concurrencia o transaccionalidad. | Migrar la persistencia local a una base de datos embebida ligera y reactiva como `Hive` o `Isar`. | Utilizar `sqflite` con una base de datos SQLite relacional (adecuada para cruces de canciones y playlists por ID). |
| **9** | **Paquete `shared_preferences` mal clasificado e inactivo:** `shared_preferences: ^2.3.2` se encuentra bajo `dev_dependencies` en `pubspec.yaml` en vez de `dependencies`, y no se utiliza en ninguna parte del código. | Mover `shared_preferences` a `dependencies` si se planea almacenar configuraciones clave-valor (ej. volumen, modo aleatorio, último tema). | Eliminarlo de `pubspec.yaml` para mantener un árbol de dependencias limpio si se opta por otra solución de persistencia. |
| **10** | **Arquitectura acoplada no adecuada (Smart UI + Singleton básico):** Las vistas contienen lógica de negocio, acceso directo al disco y estado local aislado (`setState`), impidiendo la escalabilidad y provocando desincronización de datos. | **Adoptar Arquitectura MVVM (Model-View-ViewModel):** Separar en Vistas puras, ViewModels/Controllers para gestión de estado y Repositorios para datos/audio. (Decisión acordada). | Implementar BLoC/Cubit bajo principios de Clean Architecture como alternativa de gestión de eventos/estados. |
