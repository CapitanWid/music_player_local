import 'dart:convert';
import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ScreenSelectFromLibrary extends StatefulWidget {
  const ScreenSelectFromLibrary({super.key});

  @override
  State<ScreenSelectFromLibrary> createState() => _ScreenSelectFromLibraryState();
}

class _ScreenSelectFromLibraryState extends State<ScreenSelectFromLibrary> {
  List<Map<String, dynamic>> canciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarBiblioteca();
  }

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
    } catch (_) {
      setState(() => cargando = false);
    }
  }

  Future<void> cargarMetadata(List<dynamic> data) async {
    List<Map<String, dynamic>> lista = [];

    for (var item in data) {
      final path = item["path"];
      final file = File(path);

      if (!file.existsSync()) continue;

      try {
        final tag = await AudioTags.read(file.path);
        final duracionSeg = (tag?.duration ?? 0).toDouble();
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

  String _formatMs(int ms) {
    final d = Duration(milliseconds: ms);
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seg = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$min:$seg";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleccionar cancion")),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : canciones.isEmpty
              ? const Center(
                  child: Text(
                    "No hay canciones guardadas.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: canciones.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.shade800),
                  itemBuilder: (_, i) {
                    final c = canciones[i];

                    return ListTile(
                      leading: const Icon(Icons.library_music, size: 32),
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
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () {
                        Navigator.pop(context, c);
                      },
                    );
                  },
                ),
    );
  }
}
