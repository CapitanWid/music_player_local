import 'package:flutter/material.dart';
import 'package:lalo_music_player/data/models/cancion.dart';
import 'package:lalo_music_player/services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';




class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService();
    final player = audioService.player;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      // 🔥 Se adapta al alto sin overflow
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ---------- PARTE SUPERIOR ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.deepPurple,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: ValueListenableBuilder<Cancion?>(
                  valueListenable: audioService.currentSong,
                  builder: (context, cancion, _) {
                    final hasSong = cancion != null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasSong ? cancion!.titulo : "Sin canción seleccionada",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasSong ? cancion!.artista : "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 🔥 DETECTA CUANDO TERMINA LA CANCION Y PASA A LA SIGUIENTE
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final state = snapshot.data;

              if (state?.processingState == ProcessingState.completed) {
                // Cuando termina la canción, reproducir la siguiente automáticamente
                audioService.siguiente();
              }

              return const SizedBox.shrink(); // No dibuja nada
            },
          ),


          // ---------- BARRA DE PROGRESO ----------
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final total = player.duration ?? Duration.zero;
              final progress = (total.inMilliseconds == 0)
                  ? 0.0
                  : position.inMilliseconds / total.inMilliseconds;

              return Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.deepPurple,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 11),
                      ),
                      Text(
                        _formatDuration(total),
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 10),

          // ---------- CONTROLES ----------
          ValueListenableBuilder<Cancion?>(
            valueListenable: audioService.currentSong,
            builder: (context, cancion, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      cancion != null && audioService.isFavorite(cancion)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: cancion != null &&
                              audioService.isFavorite(cancion)
                          ? Colors.red
                          : Colors.deepPurple,
                      size: 26,
                    ),
                    onPressed: () {
                      if (cancion != null) audioService.toggleFavorite(cancion);
                    },
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.deepPurple,
                      size: 30,
                    ),
                    onPressed: audioService.anterior,
                  ),

                  ValueListenableBuilder<bool>(
                    valueListenable: audioService.isPlaying,
                    builder: (context, playing, _) {
                      return IconButton(
                        icon: Icon(
                          playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: Colors.deepPurple,
                          size: 48,
                        ),
                        onPressed: () {
                          if (audioService.currentSong.value != null) {
                            audioService.togglePlayPause();
                          }
                        },
                      );
                    },
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.deepPurple,
                      size: 30,
                    ),
                    onPressed: audioService.siguiente,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
