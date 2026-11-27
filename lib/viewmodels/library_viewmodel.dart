/// ============================================================================
/// CAPA DE VISTA-MODELO (VIEWMODEL): Biblioteca Local de Música
/// ============================================================================
/// Gestiona el estado y la lógica de la pantalla de biblioteca (`ScreenLocalLibrary`).
///
/// Responsabilidades:
/// - Cargar y mantener la lista de todas las canciones disponibles en el dispositivo.
/// - Notificar los estados de carga (cargando, lista vacía, lista lista con datos, error).
/// - Manejar la selección de una canción para iniciar la reproducción en cola.
/// - Filtrar o buscar canciones en tiempo real dentro de la biblioteca.
/// ============================================================================

class LibraryViewModel {
  // TODO: Inyectar AudioRepository para obtener las canciones guardadas
  // TODO: Exponer lista reactiva de canciones (List<Cancion>) y bandera de carga (isLoading)
  // TODO: Implementar método para cargar las canciones desde el repositorio
  // TODO: Implementar método para reproducir una canción seleccionada iniciando la cola
}
