class Cancion {
  final String titulo;
  final String artista;
  final String path;        // Ruta del archivo local
  final Duration duracion;  // Duracion real del audio

  Cancion({
    required this.titulo,
    required this.artista,
    required this.path,
    required this.duracion,
  });

  // Para mostrar como texto
  String get duracionTexto {
    final minutos = duracion.inMinutes.remainder(60).toString().padLeft(2, '0');
    final segundos = duracion.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutos:$segundos";
  }

  // Para guardar en Hive o convertir a Map
  Map<String, dynamic> toMap() {
    return {
      "titulo": titulo,
      "artista": artista,
      "path": path,
      "duracion": duracion.inMilliseconds,
    };
  }

  // Para recuperar desde Hive o un Map
  static Cancion fromMap(Map<String, dynamic> map) {
    return Cancion(
      titulo: map["titulo"] ?? "Sin titulo",
      artista: map["artista"] ?? "Desconocido",
      path: map["path"],
      duracion: Duration(milliseconds: map["duracion"] ?? 0),
    );
  }
}
