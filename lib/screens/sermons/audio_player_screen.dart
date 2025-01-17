import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/sermon.dart';
import '../../widgets/player_buttons.dart';
import '../../widgets/seek_bar.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Sermon sermon;

  const AudioPlayerScreen({super.key, required this.sermon});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      setState(() => _isLoading = true);
      
      if (widget.sermon.audioUrl == null) {
        throw Exception('No audio URL available');
      }

      await _audioPlayer.setUrl(widget.sermon.audioUrl!);
      await _audioPlayer.load();
      
      setState(() {
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading audio: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initAudioPlayer,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: widget.sermon.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        widget.sermon.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.music_note,
                                            color: Colors.blue,
                                            size: 80,
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.music_note,
                                      color: Colors.blue,
                                      size: 80,
                                    ),
                            ),
                            const SizedBox(height: 32),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                widget.sermon.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.sermon.preacher,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SeekBar(
                            player: _audioPlayer,
                            onChanged: (position) {
                              _audioPlayer.seek(position);
                            },
                          ),
                          const SizedBox(height: 16),
                          PlayerButtons(player: _audioPlayer),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
