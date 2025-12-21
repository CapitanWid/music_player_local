import 'package:flutter/material.dart';
import 'package:lalo_music_player/screens/screen_local_explorer.dart';
import 'package:lalo_music_player/screens/screen_local_favoritos.dart';
import 'package:lalo_music_player/screens/screen_local_library.dart';
import 'package:lalo_music_player/screens/screen_local_playlists.dart';
import 'package:lalo_music_player/widgets/audio_player_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lalo Music Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Lalo music player'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  /// BOTÓN REDONDO BONITO CON ICONO (igual al de escaneo)
  Widget _buildMenuButton(IconData icon, String label, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// LISTA DE BOTONES
  Widget _buildScrollableButtons() {
    return ListView(
      children: [
        _buildMenuButton(Icons.search, "Buscar musica", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScreenLocalExplorer()),
          );
        }),

        _buildMenuButton(Icons.library_music, "Mi biblioteca", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScreenLocalLibrary()),
          );
        }),

        _buildMenuButton(Icons.favorite, "Favoritos", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScreenLocalFavoritos()),
          );
        }),

        _buildMenuButton(Icons.playlist_play, "Listas de reproduccion", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScreenLocalPlaylists()),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            Text(widget.title, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _buildScrollableButtons(),
      ),

      /// ⭐ SOLUCIÓN 1: SafeArea en el bottomNavigationBar
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: const AudioPlayerWidget(),
      ),
    );
  }
}
