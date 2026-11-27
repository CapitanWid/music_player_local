import 'dart:convert';
import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lalo_music_player/data/models/cancion.dart';
import 'package:lalo_music_player/services/audio_player_service.dart';

class ScreenLocalLibrary extends StatefulWidget {
  const ScreenLocalLibrary({super.key});

  @override
  State<ScreenLocalLibrary> createState() => _ScreenLocalLibraryState();
}

class _ScreenLocalLibraryState extends State<ScreenLocalLibrary> {
  List<Map<String, dynamic>> canciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarBiblioteca();
  }

  // Cargar archivo JSON
  Future<void> cargarBiblioteca() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/biblioteca_local.json");

      if (!file.existsSync()) {
        setState(() => cargando = false);
        return;
      }

      final data = jsonDecode(await file.readAsString());
      await cargarMetadata(data);
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  // Leer metadata con audiotags
  Future<void> cargarMetadata(List<dynamic> data) async {
    List<Map<String, dynamic>> lista = [];

    for (var item in data) {
      final path = item["path"];
      final file = File(path);

      if (!file.existsSync()) continue;

      try {
        final tag = await AudioTags.read(file.path);

        final rawDuracion = tag?.duration;
        final duracionSeg = rawDuracion == null ? 0.0 : rawDuracion.toDouble();
        final duracionMs = (duracionSeg * 1000).toInt();

        lista.add({
          "path": path,
          "titulo": tag?.title ?? file.path.split("/").last,
          "artista": tag?.trackArtist ?? tag?.albumArtist ?? "Desconocido",
          "duracion": duracionMs,
        });
      } catch (_) {
        lista.add({
          "path": path,
          "titulo": file.path.split("/").last,
          "artista": "Desconocido",
          "duracion": 0,
        });
      }
    }

    setState(() {
      canciones = lista;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi biblioteca")),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : canciones.isEmpty
              ? const Center(
                  child: Text(
                    "No hay canciones guardadas.\nEscanea tu telefono primero.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: canciones.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.shade800),
                  itemBuilder: (context, i) {
                    final c = canciones[i];

                    return ListTile(
                      leading: const Icon(Icons.music_note, size: 32),
                      title: Text(
                        c["titulo"],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "${c["artista"]} · ${_formatMs(c["duracion"])}",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      onTap: () {
                        final audio = AudioPlayerService();

                        final seleccion = Cancion(
                          titulo: c["titulo"],
                          artista: c["artista"],
                          path: c["path"],
                          duracion:
                              Duration(milliseconds: c["duracion"]),
                        );

                        final cola = canciones.map((m) {
                          return Cancion(
                            titulo: m["titulo"],
                            artista: m["artista"],
                            path: m["path"],
                            duracion: Duration(
                              milliseconds: m["duracion"],
                            ),
                          );
                        }).toList();

                        audio.cargarCola(cola);

                        final index = cola.indexWhere(
                          (x) => x.path == seleccion.path,
                        );

                        audio.reproducirEn(index);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Reproduciendo: ${c["titulo"]}"),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  String _formatMs(int ms) {
    final d = Duration(milliseconds: ms);
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seg = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$min:$seg";
  }
}
