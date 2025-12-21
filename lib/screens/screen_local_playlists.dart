import 'package:flutter/material.dart';
import 'package:lalo_music_player/screens/screen_playlist_detail.dart';
import 'package:lalo_music_player/services/audio_player_service.dart';
import 'package:lalo_music_player/screens/screen_local_library_add_to_playlist.dart';

class ScreenLocalPlaylists extends StatefulWidget {
  const ScreenLocalPlaylists({super.key});

  @override
  State<ScreenLocalPlaylists> createState() => _ScreenLocalPlaylistsState();
}

class _ScreenLocalPlaylistsState extends State<ScreenLocalPlaylists> {
  final audioService = AudioPlayerService();

  @override
  Widget build(BuildContext context) {
    final playlists = audioService.playlists.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Listas de reproduccion"),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crearPlaylist(context),
        icon: const Icon(Icons.add),
        label: const Text("Nueva lista"),
      ),

      body: playlists.isEmpty
          ? const Center(
              child: Text(
                "No tienes listas aun.\nCrea una nueva con el boton de abajo.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];

                return ListTile(
                  leading: const Icon(Icons.queue_music),
                  title: Text(playlist.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScreenPlaylistDetail(
                        playlistName: playlist.name,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },

                );
              },
            ),
    );
  }

  void _crearPlaylist(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nombre de la nueva lista"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Ej: Mis favoritas",
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Crear"),
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                audioService.createPlaylist(name);
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScreenLocalLibraryAddToPlaylist(
                      playlistName: name,

                      // 👇 SE AGREGA EL MISMO PARAMETRO QUE FALTABA
                      canciones: audioService.songs.value,
                    ),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          ],
        );
      },
    );
  }
}
