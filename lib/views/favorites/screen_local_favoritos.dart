import 'dart:convert';
import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:flutter/material.dart';
import 'package:lalo_music_player/data/models/cancion.dart';
import 'package:lalo_music_player/services/audio_player_service.dart';
import 'package:path_provider/path_provider.dart';

class ScreenLocalFavoritos extends StatefulWidget {
  const ScreenLocalFavoritos({super.key});

  @override
  State<ScreenLocalFavoritos> createState() => _ScreenLocalFavoritosState();
}

class _ScreenLocalFavoritosState extends State<ScreenLocalFavoritos> {
  final audio = AudioPlayerService();

  List<Cancion> favoritos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    favoritos = await audio.cargarFavoritosComoCanciones();
    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoritos"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : favoritos.isEmpty
              ? const Center(child: Text("No hay favoritos"))
              : ListView.builder(
                  itemCount: favoritos.length,
                  itemBuilder: (context, i) {
                    final c = favoritos[i];
                    return ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(c.titulo),
                      subtitle: Text(c.artista),
                      trailing: IconButton(
                        icon: Icon(
                          audio.isFavorite(c)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: audio.isFavorite(c)
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () async {
                          audio.toggleFavorite(c);
                          await _cargar();
                        },
                      ),
                      onTap: () {
                        audio.cargarCola(favoritos);
                        audio.reproducirEn(i);
                      },
                    );
                  },
                ),
    );
  }
}
