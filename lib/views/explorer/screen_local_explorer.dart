import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ScreenLocalExplorer extends StatefulWidget {
  const ScreenLocalExplorer({super.key});

  @override
  State<ScreenLocalExplorer> createState() => _ScreenLocalExplorerState();
}

class _ScreenLocalExplorerState extends State<ScreenLocalExplorer> {
  bool escaneando = false;
  double progreso = 0.0;
  List<FileSystemEntity> archivosEncontrados = [];
  String estadoTexto = "Listo para escanear";

  // ================================
  //   ESCANEAR DIRECTORIOS
  // ================================
  Future<void> iniciarEscaneo() async {
    final permisoAudio = await Permission.audio.request();
    await Permission.storage.request();

    if (!permisoAudio.isGranted) {
      setState(() => estadoTexto = "Permiso denegado");
      return;
    }

    setState(() {
      escaneando = true;
      progreso = 0;
      archivosEncontrados.clear();
      estadoTexto = "Escaneando...";
    });

    final raiz = Directory("/storage/emulated/0/");

    await escanearDirectorio(raiz);

    await guardarBiblioteca(archivosEncontrados);

    setState(() {
      escaneando = false;
      progreso = 1;
      estadoTexto =
          "Escaneo completado: ${archivosEncontrados.length} canciones.";
    });

    // ===============================
    //  🔔 MENSAJE DE FINALIZACION
    // ===============================
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Escaneo completado: ${archivosEncontrados.length} canciones encontradas.",
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> escanearDirectorio(Directory dir) async {
    try {
      // Nombre de la carpeta
      final nombreCarpeta = dir.path.split("/").last.toLowerCase();

      // Evitar carpetas totalmente bloqueadas por Android
      if (nombreCarpeta == "android" ||
          nombreCarpeta == "data" ||
          nombreCarpeta == "obb") {
        return;
      }

      final elementos = dir.listSync();

      for (final entity in elementos) {
        // Si es carpeta, entrar recursivamente
        if (entity is Directory) {
          await escanearDirectorio(entity);
        }

        // Si es archivo
        if (entity is File) {
          final path = entity.path.toLowerCase();

          if (path.endsWith(".mp3") ||
              path.endsWith(".m4a") ||
              path.endsWith(".wav") ||
              path.endsWith(".aac") ||
              path.endsWith(".flac")) {
            archivosEncontrados.add(entity);
          }
        }
      }

    } catch (e) {
      // Si una carpeta da error, se ignora y seguimos sin romper
      return;
    }
  }


  // =======================================================
  //   GUARDAR RESULTADOS EN JSON LOCAL (biblioteca)
  // =======================================================
  Future<void> guardarBiblioteca(List<FileSystemEntity> archivos) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/biblioteca_local.json");

    List<Map<String, String>> data = archivos.map((e) {
      return {
        "path": e.path,
        "titulo": e.path.split("/").last,
      };
    }).toList();

    await file.writeAsString(jsonEncode(data));
  }

  // =======================================================
  //   LEER BIBLIOTECA LOCAL
  // =======================================================
  Future<List<Map<String, dynamic>>> leerBiblioteca() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/biblioteca_local.json");

    if (!file.existsSync()) return [];

    final contenido = await file.readAsString();
    return List<Map<String, dynamic>>.from(jsonDecode(contenido));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscar musica en el telefono"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!escaneando)
              ElevatedButton(
                onPressed: iniciarEscaneo,
                child: const Text("Iniciar escaneo"),
              ),

            if (escaneando) ...[
              Text(estadoTexto),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: progreso),
            ],

            const SizedBox(height: 25),

            Expanded(
              child: ListView.builder(
                itemCount: archivosEncontrados.length,
                itemBuilder: (context, i) {
                  final file = archivosEncontrados[i];
                  return ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(file.path.split("/").last),
                    //subtitle: Text(file.path),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
