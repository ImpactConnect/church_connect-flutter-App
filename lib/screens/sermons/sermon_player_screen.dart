import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../models/sermon.dart';
import 'dart:ui';

class SermonPlayerScreen extends StatefulWidget {
  final Sermon sermon;

  const SermonPlayerScreen({
    Key? key,
    required this.sermon,
  }) : super(key: key);

  @override
  State<SermonPlayerScreen> createState() => _SermonPlayerScreenState();
}

class _SermonPlayerScreenState extends State<SermonPlayerScreen> with SingleTickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  late AnimationController _playPauseController;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  String? _error;

  final List<double> _playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioService.init(
      widget.sermon.audioUrl!,
      widget.sermon.title,
      widget.sermon.preacher,
    );

    _audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (_isPlaying) {
            _playPauseController.forward();
          } else {
            _playPauseController.reverse();
          }
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

  Widget _buildBlurredBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.sermon.imageUrl ?? 
            'https://picsum.photos/800/800'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.black.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildSermonInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(widget.sermon.imageUrl ?? 
                'https://picsum.photos/800/800'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          widget.sermon.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.sermon.preacher,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressBar(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.shuffle_rounded,
                size: 28,
                onPressed: () {
                  // Implement shuffle
                },
              ),
              _buildControlButton(
                icon: Icons.skip_previous_rounded,
                size: 32,
                onPressed: () {
                  // Play previous sermon
                  _playPreviousSermon();
                },
              ),
              _buildPlayPauseButton(),
              _buildControlButton(
                icon: Icons.skip_next_rounded,
                size: 32,
                onPressed: () {
                  // Play next sermon
                  _playNextSermon();
                },
              ),
              _buildControlButton(
                icon: Icons.repeat_rounded,
                size: 28,
                onPressed: () {
                  // Implement repeat
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildControlButton(
                icon: Icons.volume_up_rounded,
                size: 24,
                onPressed: () {
                  _showVolumeSlider(context);
                },
              ),
              StreamBuilder<double>(
                stream: _audioService.playbackSpeedStream,
                builder: (context, snapshot) {
                  return TextButton(
                    onPressed: () => _showPlaybackSpeedDialog(context),
                    child: Text(
                      '${snapshot.data?.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: size,
            color: isActive ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return StreamBuilder<bool>(
      stream: _audioService.isPlayingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isPlaying) {
                  _audioService.pause();
                } else {
                  _audioService.play();
                }
              },
              customBorder: const CircleBorder(),
              child: Center(
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _playPauseController,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _playNextSermon() {
    // TODO: Implement next sermon logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Next sermon feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _playPreviousSermon() {
    // TODO: Implement previous sermon logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Previous sermon feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showVolumeSlider(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Volume',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder<double>(
              stream: _audioService.volumeStream,
              builder: (context, snapshot) {
                final volume = snapshot.data ?? 1.0;
                return Slider(
                  value: volume,
                  onChanged: (value) {
                    _audioService.setVolume(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey[800],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return StreamBuilder<PositionData>(
      stream: _audioService.positionDataStream,
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
                    max: positionData.duration.inMilliseconds.toDouble(),
                    onChanged: null,
                    activeColor: Colors.white.withOpacity(0.3),
                    inactiveColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                // Playback progress
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.2),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: positionData.position.inMilliseconds.toDouble(),
                    min: 0,
                    max: positionData.duration.inMilliseconds.toDouble(),
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(positionData.position),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    _formatDuration(positionData.duration),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPlaybackSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _playbackSpeeds.map((speed) {
            return ListTile(
              title: Text('${speed}x'),
              onTap: () {
                _audioService.setPlaybackSpeed(speed);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBlurredBackground(),
          SafeArea(
            child: StreamBuilder<bool>(
              stream: _audioService.loadingStream,
              builder: (context, loadingSnapshot) {
                if (loadingSnapshot.data == true) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }

                return StreamBuilder<bool>(
                  stream: _audioService.isInitializedStream,
                  builder: (context, snapshot) {
                    if (snapshot.data != true) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load audio',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _initAudio,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down),
                                onPressed: () {
                                  _audioService.stop();
                                  Navigator.pop(context);
                                },
                                color: Colors.white,
                                iconSize: 32,
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  // Show more options
                                },
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        if (_error != null)
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const Spacer(flex: 1),
                        _buildSermonInfo(),
                        const Spacer(flex: 2),
                        _buildPlaybackControls(),
                        const SizedBox(height: 48),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    _audioService.dispose();
    super.dispose();
  }
}
