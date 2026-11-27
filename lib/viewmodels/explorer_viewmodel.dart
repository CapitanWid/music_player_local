/// ============================================================================
/// CAPA DE VISTA-MODELO (VIEWMODEL): Explorador / Escáner de Música
/// ============================================================================
/// Gestiona el estado y la lógica de la pantalla de escaneo (`ScreenLocalExplorer`).
///
/// Responsabilidades:
/// - Solicitar y gestionar los permisos de acceso al almacenamiento del dispositivo.
/// - Iniciar el proceso de escaneo de archivos de audio locales en segundo plano.
/// - Notificar el progreso del escaneo a la vista (porcentaje, canciones encontradas, estado actual).
/// - Guardar los resultados en el repositorio al terminar el escaneo.
/// ============================================================================

class ExplorerViewModel {
  // TODO: Inyectar AudioRepository y permisos para iniciar el escaneo
  // TODO: Exponer estado reactivo: escaneando (bool), progreso (double), archivos encontrados (List)
  // TODO: Implementar método iniciarEscaneo() que corra de forma asíncrona / Isolate
}
