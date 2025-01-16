import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' show Random;
import '../../models/sermon.dart';
import '../../models/position_data.dart';
import '../../services/supabase_sermon_service.dart';

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
  final _sermonService = SupabaseSermonService();
  bool _isInitialized = false;
  List<Sermon> _relatedSermons = [];
  bool _isLoadingRelated = true;
  late Sermon _currentSermon;
  final _scrollController = ScrollController();
  bool _showMiniPlayer = false;
  bool _isBookmarked = false;
  final bool _showLyrics = false;
  bool _showNotes = false;
  String _userNotes = '';
  double _volume = 1.0;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentSermon = widget.sermon;
    _player = AudioPlayer();
    _initAudioPlayer();
    _loadRelatedSermons();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final showMiniPlayer = _scrollController.offset > 300;
    if (showMiniPlayer != _showMiniPlayer) {
      setState(() => _showMiniPlayer = showMiniPlayer);
    }
  }

  Future<void> _initAudioPlayer() async {
    try {
      final url = _currentSermon.audioUrl ?? '';
      if (url.isEmpty) {
        print('No audio URL available');
        return;
      }
      await _player.setUrl(url);

      // Restore previous position if exists
      if (_currentSermon.progress != null && _currentSermon.progress! > 0) {
        final duration = _player.duration;
        if (duration != null) {
          final position = duration * _currentSermon.progress!;
          await _player.seek(position);
        }
      }

      setState(() => _isInitialized = true);

      // Start playing automatically
      _player.play();

      // Update progress periodically
      _player.positionStream.listen((position) async {
        if (!mounted) return;
        final duration = _player.duration;
        if (duration != null && duration.inMilliseconds > 0) {
          final progress = position.inMilliseconds / duration.inMilliseconds;
          try {
            await _sermonService.updateProgress(_currentSermon.id, progress);
          } catch (e) {
            debugPrint('Error updating progress: $e');
          }
        }
      });
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
          position,
          bufferedPosition,
          duration ?? Duration.zero,
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
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    _player.stop().then((_) {
      _player.dispose();
    });
    super.dispose();
  }

  void _shareSermon() {
    final message =
        'Listen to "${_currentSermon.title}" by ${_currentSermon.preacher}';
    Share.share(message);
  }

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    // TODO: Implement bookmark functionality
  }

  Future<void> _loadRelatedSermons() async {
    try {
      final sermons = await _sermonService.getRelatedSermons(_currentSermon.id);
      if (mounted) {
        setState(() {
          _relatedSermons = sermons;
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading related sermons: $e');
      if (mounted) {
        setState(() => _isLoadingRelated = false);
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (_currentSermon.imageUrl != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: _currentSermon.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.church, size: 50),
                ),
              ),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentSermon.seriesName != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _currentSermon.seriesName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  _currentSermon.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      _currentSermon.preacher,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data ??
                  PositionData(Duration.zero, Duration.zero, Duration.zero);

              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: Theme.of(context).primaryColor,
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: Theme.of(context).primaryColor,
                      overlayColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                    child: Slider(
                      min: 0,
                      max: positionData.duration.inMilliseconds.toDouble(),
                      value: positionData.position.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        _player.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(positionData.position),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          _formatDuration(positionData.duration),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _isBookmarked
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                ),
                onPressed: _toggleBookmark,
              ),
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () {
                  final newPosition =
                      _player.position - const Duration(seconds: 10);
                  _player.seek(newPosition);
                },
                color: Colors.grey[800],
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
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  }

                  if (playing != true) {
                    return Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 32,
                        color: Colors.white,
                        onPressed: _player.play,
                      ),
                    );
                  }

                  return Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.pause),
                      iconSize: 32,
                      color: Colors.white,
                      onPressed: _player.pause,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.forward_30),
                onPressed: () {
                  final newPosition =
                      _player.position + const Duration(seconds: 30);
                  _player.seek(newPosition);
                },
                color: Colors.grey[800],
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareSermon,
                color: Colors.grey[600],
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<double>(
            stream: _player.speedStream,
            builder: (context, snapshot) {
              final speed = snapshot.data ?? 1.0;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.speed, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${speed}x',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ).onTap(() {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Playback Speed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...[
                          '0.5x',
                          '0.75x',
                          '1.0x',
                          '1.25x',
                          '1.5x',
                          '1.75x',
                          '2.0x'
                        ].map((speed) => ListTile(
                              title: Text(speed),
                              onTap: () {
                                Navigator.pop(context);
                                _player.setSpeed(
                                  double.parse(speed.replaceAll('x', '')),
                                );
                              },
                            )),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: _showMiniPlayer ? 0 : -80,
      height: 80,
      child: Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (_currentSermon.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: _currentSermon.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentSermon.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _currentSermon.preacher,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final playing = playerState?.playing;

                if (playing == true) {
                  return IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: _player.pause,
                    color: Theme.of(context).primaryColor,
                  );
                }

                return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: _player.play,
                  color: Theme.of(context).primaryColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioWaveform(Duration position, Duration duration) {
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;
    final random = Random();
    return SizedBox(
      height: 40,
      child: Row(
        children: List.generate(30, (index) {
          final barHeight =
              (index % 2 == 0 ? 0.5 : 1.0) * (0.3 + 0.7 * random.nextDouble());
          final isActive = index / 30 <= progress;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Container(
                height: 20 * barHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVolumeControl() {
    return Row(
      children: [
        IconButton(
          icon: Icon(_volume == 0
              ? Icons.volume_off
              : _volume < 0.5
                  ? Icons.volume_down
                  : Icons.volume_up),
          onPressed: () {
            setState(() {
              _volume = _volume == 0 ? 1.0 : 0.0;
            });
            _player.setVolume(_volume);
          },
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 4,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 8,
              ),
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Colors.grey[300],
              thumbColor: Theme.of(context).primaryColor,
            ),
            child: Slider(
              value: _volume,
              onChanged: (value) {
                setState(() => _volume = value);
                _player.setVolume(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showNotes ? 200 : 0,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Take notes while listening...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (value) {
                setState(() => _userNotes = value);
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Notes'),
                  onPressed: () {
                    // TODO: Implement notes saving functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notes saved!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveHeader() {
    return Stack(
      children: [
        _buildHeader(),
        Positioned(
          top: 40,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 16,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(
                    _showNotes ? Icons.note : Icons.note_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(() => _showNotes = !_showNotes),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _shareSermon,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _player.stop();
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _buildInteractiveHeader(),
                ),
                if (_showNotes)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildNotesSection(),
                    ),
                  ),
                if (_currentSermon.description != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About this Sermon',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentSermon.description!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      StreamBuilder<PositionData>(
                        stream: _positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data ??
                              PositionData(
                                  Duration.zero, Duration.zero, Duration.zero);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildAudioWaveform(
                              positionData.position,
                              positionData.duration,
                            ),
                          );
                        },
                      ),
                      _buildPlayerControls(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildVolumeControl(),
                      ),
                    ],
                  ),
                ),
                if (_relatedSermons.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Related Sermons',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Implement view all related sermons
                                },
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _relatedSermons.length,
                              itemBuilder: (context, index) {
                                final sermon = _relatedSermons[index];
                                return Container(
                                  width: 180,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          if (sermon.imageUrl != null)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: sermon.imageUrl!,
                                                height: 120,
                                                width: 180,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                sermon.seriesName ?? '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        sermon.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        sermon.preacher,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).onTap(() {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SermonPlayerScreen(sermon: sermon),
                                    ),
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            _buildMiniPlayer(),
          ],
        ),
      ),
    );
  }
}

extension _GestureX on Widget {
  Widget onTap(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: this,
      );
}
