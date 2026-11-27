/// ============================================================================
/// CAPA DE VISTA-MODELO (VIEWMODEL): Reproductor de Audio
/// ============================================================================
/// Gestiona todo el estado de la reproducción actual y sirve de puente entre
/// el widget de reproducción (`AudioPlayerWidget`) y el servicio de audio.
///
/// Responsabilidades:
/// - Exponer la canción en reproducción actual y su estado (reproduciendo / pausado / cargando).
/// - Exponer la posición actual y duración total del audio para la barra de progreso (Seek).
/// - Exponer la cola de reproducción actual y el índice activo.
/// - Manejar las acciones de usuario: Play, Pausa, Siguiente, Anterior, Rebobinado y Cambio de Posición.
/// ============================================================================

class PlayerViewModel {
  // TODO: Conectar con AudioPlayerService para suscribirse a los eventos del reproductor
  // TODO: Exponer variables reactivas de estado (canción actual, estado de reproducción, posición y duración)
  // TODO: Implementar métodos de control: play(), pause(), togglePlayPause(), siguiente(), anterior(), seek()
}
