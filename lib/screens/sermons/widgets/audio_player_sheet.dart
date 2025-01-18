import 'package:flutter/material.dart';
import '../../../services/audio_service.dart';

class AudioPlayerSheet extends StatefulWidget {
  final String title;
  final String preacher;
  final String audioUrl;

  const AudioPlayerSheet({
    Key? key,
    required this.title,
    required this.preacher,
    required this.audioUrl,
  }) : super(key: key);

  @override
  State<AudioPlayerSheet> createState() => _AudioPlayerSheetState();
}

class _AudioPlayerSheetState extends State<AudioPlayerSheet> {
  final _audioService = AudioService();
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;
  String? _error;

  final List<double> _playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioService.init(widget.audioUrl, widget.title, widget.preacher);
    
    _audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    _audioService.playbackSpeedStream.listen((speed) {
      if (mounted) {
        setState(() {
          _playbackSpeed = speed;
        });
      }
    });

    _audioService.volumeStream.listen((volume) {
      if (mounted) {
        setState(() {
          _volume = volume;
        });
      }
    });

    _audioService.errorStream.listen((error) {
      if (mounted && error != null) {
        setState(() {
          _error = error;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Start playing automatically
    _audioService.play();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  Widget _buildPlaybackSpeedButton() {
    return PopupMenuButton<double>(
      icon: Text('${_playbackSpeed}x', 
        style: const TextStyle(fontWeight: FontWeight.bold)),
      onSelected: _audioService.setPlaybackSpeed,
      itemBuilder: (context) => _playbackSpeeds
          .map((speed) => PopupMenuItem(
                value: speed,
                child: Text('${speed}x'),
              ))
          .toList(),
    );
  }

  Widget _buildVolumeControl() {
    return Row(
      children: [
        Icon(
          _volume <= 0 ? Icons.volume_off : Icons.volume_up,
          size: 20,
        ),
        Expanded(
          child: Slider(
            value: _volume,
            min: 0.0,
            max: 1.0,
            onChanged: _audioService.setVolume,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.audiotrack, size: 48),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.preacher,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPlaybackSpeedButton(),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: _audioService.seekBackward,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      iconSize: 48,
                      onPressed: () {
                        if (_isPlaying) {
                          _audioService.pause();
                        } else {
                          _audioService.play();
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: _audioService.seekForward,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildVolumeControl(),
                ),
                const SizedBox(height: 16),
                StreamBuilder<PositionData>(
                  stream: _audioService.positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ??
                        PositionData(
                          position: Duration.zero,
                          bufferedPosition: Duration.zero,
                          duration: Duration.zero,
                        );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              // Buffered progress
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: SliderComponentShape.noThumb,
                                  overlayShape: SliderComponentShape.noOverlay,
                                  valueIndicatorShape: SliderComponentShape.noOverlay,
                                  trackShape: const RectangularSliderTrackShape(),
                                ),
                                child: Slider(
                                  value: positionData.bufferedPosition.inMilliseconds
                                      .toDouble(),
                                  min: 0,
                                  max: positionData.duration.inMilliseconds
                                      .toDouble(),
                                  onChanged: null,
                                  activeColor: Colors.grey[300],
                                  inactiveColor: Colors.grey[100],
                                ),
                              ),
                              // Playback progress
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                ),
                                child: Slider(
                                  value: positionData.position.inMilliseconds
                                      .toDouble(),
                                  min: 0,
                                  max: positionData.duration.inMilliseconds
                                      .toDouble(),
                                  onChanged: (value) {
                                    _audioService.seek(
                                      Duration(milliseconds: value.toInt()),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(positionData.position),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text(
                                  _formatDuration(positionData.duration),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
