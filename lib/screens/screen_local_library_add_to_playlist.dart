import 'package:flutter/material.dart';
import 'package:lalo_music_player/model/cancion.dart';
import 'package:lalo_music_player/services/audio_player_service.dart';

class ScreenLocalLibraryAddToPlaylist extends StatelessWidget {
  final String playlistName;
  final List<Cancion> canciones;

  const ScreenLocalLibraryAddToPlaylist({
    super.key,
    required this.playlistName,
    required this.canciones,
  });

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar a: $playlistName"),
      ),
      body: ValueListenableBuilder(
        valueListenable: audioService.playlists,
        builder: (context, playlists, _) {
          final playlist = playlists.firstWhere((p) => p.name == playlistName);

          return ListView.builder(
            itemCount: canciones.length,
            itemBuilder: (context, index) {
              final c = canciones[index];
              final yaEsta = playlist.songs.any((x) => x.path == c.path);

              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(c.titulo),
                subtitle: Text(c.artista),
                trailing: IconButton(
                  icon: Icon(
                    yaEsta ? Icons.check : Icons.add,
                    color: yaEsta ? Colors.green : Colors.deepPurple,
                  ),
                  onPressed: () {
                    audioService.addSongToPlaylist(playlistName, c);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          yaEsta
                              ? "Ya estaba en la lista"
                              : "Agregada a $playlistName",
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
