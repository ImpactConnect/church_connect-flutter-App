import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/sermon.dart';

class SermonPlayerScreen extends StatefulWidget {
  final Sermon sermon;

  const SermonPlayerScreen({
    super.key,
    required this.sermon,
  });

  @override
  State<SermonPlayerScreen> createState() => _SermonPlayerScreenState();
}

class _SermonPlayerScreenState extends State<SermonPlayerScreen> {
  late AudioPlayer _player;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _player.setUrl(widget.sermon.audioUrl);
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position: position,
          bufferedPosition: bufferedPosition,
          duration: duration ?? Duration.zero,
        ),
      );

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'sermon_icon',
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.headphones,
                        size: 50,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      widget.sermon.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.sermon.preacher,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.sermon.category,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ??
                        PositionData(
                          position: Duration.zero,
                          bufferedPosition: Duration.zero,
                          duration: Duration.zero,
                        );

                    return Column(
                      children: [
                        Stack(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                              ),
                              child: Slider(
                                min: 0,
                                max: positionData.duration.inMilliseconds
                                    .toDouble(),
                                value: positionData.position.inMilliseconds
                                    .toDouble(),
                                onChanged: (value) {
                                  _player.seek(Duration(
                                      milliseconds: value.toInt()));
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(positionData.position)),
                              Text(_formatDuration(positionData.duration)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: () {
                        final newPosition = _player.position -
                            const Duration(seconds: 10);
                        _player.seek(newPosition);
                      },
                    ),
                    StreamBuilder<PlayerState>(
                      stream: _player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;

                        if (!_isInitialized ||
                            processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return Container(
                            width: 64,
                            height: 64,
                            padding: const EdgeInsets.all(8),
                            child: const CircularProgressIndicator(),
                          );
                        } else if (playing != true) {
                          return IconButton(
                            iconSize: 64,
                            icon: const Icon(Icons.play_circle),
                            onPressed: _player.play,
                          );
                        } else {
                          return IconButton(
                            iconSize: 64,
                            icon: const Icon(Icons.pause_circle),
                            onPressed: _player.pause,
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: () {
                        final newPosition = _player.position +
                            const Duration(seconds: 10);
                        _player.seek(newPosition);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });
}
