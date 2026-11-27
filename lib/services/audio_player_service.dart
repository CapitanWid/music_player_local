import 'dart:convert';
import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lalo_music_player/data/models/cancion.dart';
import 'package:path_provider/path_provider.dart';

/// ===============================================
/// PLAYLIST CLASS - DEBE IR FUERA DEL SERVICIO
/// ===============================================
class Playlist {
  final String name;
  final List<Cancion> songs;

  Playlist({
    required this.name,
    required this.songs,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "songs": songs.map((c) => c.path).toList(),
      };

  static Playlist fromJson(Map<String, dynamic> json, List<Cancion> todas) {
    final paths = (json["songs"] as List).map((e) => e.toString()).toList();

    final listaCanciones = todas.where((c) => paths.contains(c.path)).toList();

    return Playlist(name: json["name"], songs: listaCanciones);
  }
}

/// ===============================================
/// AUDIO PLAYER SERVICE
/// ===============================================
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  AudioPlayerService._internal() {
    player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    _cargarFavoritos();
    _cargarPlaylists();
  }

  final AudioPlayer player = AudioPlayer();

  final ValueNotifier<Cancion?> currentSong = ValueNotifier(null);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  /// ====================================================
  ///  CANCIONES DE LA BIBLIOTECA
  /// ====================================================
  ValueNotifier<List<Cancion>> songs = ValueNotifier([]);

  void setSongs(List<Cancion> lista) {
    songs.value = lista;
  }


  List<Cancion> playQueue = [];
  int currentIndex = 0;

  final List<String> favoritePaths = [];

  /// ====================================================
  ///  PLAYLISTS
  /// ====================================================
  ValueNotifier<List<Playlist>> playlists = ValueNotifier([]);

  // Archivo donde se guardan playlists
  Future<File> _getPlaylistFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/playlists.json");
  }

  Future<void> _guardarPlaylists() async {
    try {
      final file = await _getPlaylistFile();
      final json = playlists.value.map((p) => p.toJson()).toList();
      await file.writeAsString(jsonEncode(json));
    } catch (e) {
      print("Error guardando playlists: $e");
    }
  }

  Future<void> _cargarPlaylists() async {
    try {
      final file = await _getPlaylistFile();
      if (!file.existsSync()) return;

      final data = await file.readAsString();
      final decoded = jsonDecode(data) as List;

      // Necesitamos cargar TODAS las canciones igual que en la libreria
      // Esto lo debe hacer tu ScreenLibrary y pasarlo aquí si quieres sincronizar
      // Por ahora lo dejamos vacío:
      //List<Cancion> todasLasCanciones = [];
      List<Cancion> todasLasCanciones = songs.value;


      playlists.value = decoded
          .map((p) => Playlist.fromJson(p, todasLasCanciones))
          .toList();
    } catch (e) {
      print("Error cargando playlists: $e");
    }
  }

  void createPlaylist(String name) {
    playlists.value = [
      ...playlists.value,
      Playlist(name: name, songs: [])
    ];
    _guardarPlaylists();
  }

  void addSongToPlaylist(String playlistName, Cancion song) {
    final updated = playlists.value.map((p) {
      if (p.name == playlistName) {
        return Playlist(
          name: p.name,
          songs: [...p.songs, song],
        );
      }
      return p;
    }).toList();

    playlists.value = updated;
    _guardarPlaylists();
  }

  /// ====================================================
  /// FAVORITOS (SIN CAMBIOS)
  /// ====================================================
  void toggleFavorite(Cancion c) {
    if (favoritePaths.contains(c.path)) {
      favoritePaths.remove(c.path);
    } else {
      favoritePaths.add(c.path);
    }

    _guardarFavoritos();
    currentSong.notifyListeners();
  }

  bool isFavorite(Cancion c) => favoritePaths.contains(c.path);

  Future<List<Cancion>> cargarFavoritosComoCanciones() async {
    List<Cancion> salida = [];

    for (var path in favoritePaths) {
      final file = File(path);
      if (!file.existsSync()) continue;

      try {
        final tag = await AudioTags.read(path);
        final rawDur = tag?.duration;
        final durSeg = rawDur == null ? 0.0 : rawDur.toDouble();
        final durMs = (durSeg * 1000).toInt();

        salida.add(
          Cancion(
            titulo: tag?.title ?? file.path.split("/").last,
            artista: tag?.trackArtist ?? tag?.albumArtist ?? "Desconocido",
            path: path,
            duracion: Duration(milliseconds: durMs),
          ),
        );
      } catch (_) {
        salida.add(
          Cancion(
            titulo: file.path.split("/").last,
            artista: "Desconocido",
            path: path,
            duracion: Duration.zero,
          ),
        );
      }
    }

    return salida;
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/favoritos.json");
  }

  Future<void> _guardarFavoritos() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(favoritePaths));
    } catch (e) {}
  }

  Future<void> _cargarFavoritos() async {
    try {
      final file = await _getFile();
      if (!file.existsSync()) return;

      final data = await file.readAsString();
      final decoded = jsonDecode(data) as List;

      favoritePaths
        ..clear()
        ..addAll(decoded.map((e) => e.toString()));
    } catch (e) {}
  }

  /// ====================================================
  /// CONTROL DE REPRODUCCION
  /// ====================================================
  Future<void> playSong(Cancion c) async {
    try {
      isLoading.value = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentSong.value = c;
      });

      await player.setAudioSource(
        AudioSource.uri(
          Uri.file(c.path),
          tag: MediaItem(
            id: c.path,
            title: c.titulo,
            artist: c.artista,
          ),
        ),
      );

      await player.play();
    } catch (e) {
      print("Error al reproducir: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void cargarCola(List<Cancion> canciones) {
    playQueue = canciones;
    currentIndex = 0;

    if (canciones.isNotEmpty) playSong(canciones[0]);
  }

  Future<void> reproducirEn(int index) async {
    if (index < 0 || index >= playQueue.length) return;

    currentIndex = index;
    await playSong(playQueue[index]);
  }

  void siguiente() {
    if (currentIndex < playQueue.length - 1) {
      currentIndex++;
      reproducirEn(currentIndex);
    }
  }

  void anterior() {
    if (currentIndex > 0) {
      currentIndex--;
      reproducirEn(currentIndex);
    }
  }

  Future<void> togglePlayPause() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  void reset() {
    currentSong.value = null;
    isPlaying.value = false;
    isLoading.value = false;
    playQueue.clear();
    currentIndex = 0;
    player.stop();
  }
}
