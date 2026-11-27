import 'package:flutter/material.dart';
import 'package:lalo_music_player/data/models/cancion.dart';
import 'package:lalo_music_player/views/library/screen_select_from_library.dart';
import 'package:lalo_music_player/services/audio_player_service.dart';

class ScreenPlaylistDetail extends StatelessWidget {
  final String playlistName;

  const ScreenPlaylistDetail({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService();

    return ValueListenableBuilder(
      valueListenable: audioService.playlists,
      builder: (context, playlists, _) {
        final playlist = playlists.firstWhere((p) => p.name == playlistName);

        return Scaffold(
          appBar: AppBar(
            title: Text("Lista: $playlistName"),
          ),

          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text("Agregar cancion"),
            onPressed: () async {
              final seleccion = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScreenSelectFromLibrary(),
                ),
              );

              if (seleccion != null) {
                // Convertimos la duracion a Duration real
                final Duration dur = Duration(
                  milliseconds: seleccion["duracion"],
                );

                // Creamos el objeto Cancion con los datos correctos
                final nueva = Cancion(
                  titulo: seleccion["titulo"],
                  artista: seleccion["artista"],
                  path: seleccion["path"],
                  duracion: dur,
                );

                // Agregamos a la playlist
                audioService.addSongToPlaylist(
                  playlistName,
                  nueva,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("Agregada: ${seleccion["titulo"]}"),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),

          body: playlist.songs.isEmpty
              ? const Center(
                  child: Text(
                    "Aun no hay canciones en esta lista.",
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: playlist.songs.length,
                  itemBuilder: (context, index) {
                    final Cancion s = playlist.songs[index];

                    return ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(s.titulo),
                      subtitle: Text(s.artista),
                    );
                  },
                ),
        );
      },
    );
  }
}
