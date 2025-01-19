import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _audioPlayer;
  final _playbackSpeedController = BehaviorSubject<double>.seeded(1.0);
  final _volumeController = BehaviorSubject<double>.seeded(1.0);
  final _errorController = BehaviorSubject<String?>.seeded(null);
  final _loadingController = BehaviorSubject<bool>.seeded(false);
  final _isInitializedController = BehaviorSubject<bool>.seeded(false);

  Stream<Duration?> get positionStream =>
      _audioPlayer?.positionStream ?? Stream.value(null);
  Stream<Duration?> get durationStream =>
      _audioPlayer?.durationStream ?? Stream.value(null);
  Stream<PlayerState> get playerStateStream =>
      _audioPlayer?.playerStateStream ??
      Stream.value(PlayerState(false, ProcessingState.idle));
  Stream<double> get playbackSpeedStream => _playbackSpeedController.stream;
  Stream<double> get volumeStream => _volumeController.stream;
  Stream<String?> get errorStream => _errorController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<bool> get isInitializedStream => _isInitializedController.stream;
  Stream<bool> get isPlayingStream =>
      _audioPlayer?.playingStream ?? Stream.value(false);

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration?, Duration?, Duration?, PositionData>(
        positionStream,
        _audioPlayer?.bufferedPositionStream ?? Stream.value(null),
        durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position: position ?? Duration.zero,
          bufferedPosition: bufferedPosition ?? Duration.zero,
          duration: duration ?? Duration.zero,
        ),
      );

  Future<void> init(String url, String title, String artist) async {
    try {
      _loadingController.add(true);
      _errorController.add(null);
      _isInitializedController.add(false);

      // Dispose of previous player if exists
      await dispose();

      // Create new player instance
      _audioPlayer = AudioPlayer();

      // Set up error handling
      _audioPlayer!.playbackEventStream.listen(
        (event) {},
        onError: (Object e, StackTrace stackTrace) {
          debugPrint('A stream error occurred: $e');
          _errorController.add('Error streaming audio: $e');
        },
      );

      // Initialize audio source
      try {
        await _audioPlayer!.setAudioSource(
          AudioSource.uri(
            Uri.parse(url),
            tag: MediaItem(
              id: url,
              title: title,
              artist: artist,
            ),
          ),
        );

        await _audioPlayer!.setVolume(_volumeController.value);
        await _audioPlayer!.setSpeed(_playbackSpeedController.value);

        _isInitializedController.add(true);
      } catch (e) {
        _errorController.add('Error loading audio: $e');
        rethrow;
      }
    } catch (e) {
      _errorController.add('Error initializing audio player: $e');
      if (kDebugMode) {
        print('Error initializing audio player: $e');
      }
      rethrow;
    } finally {
      _loadingController.add(false);
    }
  }

  Future<void> play() async {
    if (!(_isInitializedController.value)) {
      _errorController.add('Audio player not initialized');
      return;
    }

    try {
      await _audioPlayer?.play();
    } catch (e) {
      _errorController.add('Error playing audio: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    if (!(_isInitializedController.value)) return;

    try {
      await _audioPlayer?.pause();
    } catch (e) {
      _errorController.add('Error pausing audio: $e');
      rethrow;
    }
  }

  Future<void> seek(Duration position) async {
    if (!(_isInitializedController.value)) return;

    try {
      await _audioPlayer?.seek(position);
    } catch (e) {
      _errorController.add('Error seeking audio: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    if (!(_isInitializedController.value)) return;

    try {
      await _audioPlayer?.stop();
    } catch (e) {
      _errorController.add('Error stopping audio: $e');
      rethrow;
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    if (!(_isInitializedController.value)) return;

    try {
      await _audioPlayer?.setSpeed(speed);
      _playbackSpeedController.add(speed);
    } catch (e) {
      _errorController.add('Error setting playback speed: $e');
      rethrow;
    }
  }

  Future<void> setVolume(double volume) async {
    if (!(_isInitializedController.value)) return;

    try {
      await _audioPlayer?.setVolume(volume);
      _volumeController.add(volume);
    } catch (e) {
      _errorController.add('Error setting volume: $e');
      rethrow;
    }
  }

  Future<void> seekForward() async {
    if (!(_isInitializedController.value)) return;

    try {
      final position = _audioPlayer?.position;
      final duration = _audioPlayer?.duration;
      if (position != null && duration != null) {
        final newPosition = position + const Duration(seconds: 10);
        if (newPosition < duration) {
          await _audioPlayer?.seek(newPosition);
        } else {
          await _audioPlayer?.seek(duration);
        }
      }
    } catch (e) {
      _errorController.add('Error seeking forward: $e');
      rethrow;
    }
  }

  Future<void> seekBackward() async {
    if (!(_isInitializedController.value)) return;

    try {
      final position = _audioPlayer?.position;
      if (position != null) {
        final newPosition = position - const Duration(seconds: 10);
        if (newPosition > Duration.zero) {
          await _audioPlayer?.seek(newPosition);
        } else {
          await _audioPlayer?.seek(Duration.zero);
        }
      }
    } catch (e) {
      _errorController.add('Error seeking backward: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      await _audioPlayer?.stop();
      await _audioPlayer?.dispose();
      _audioPlayer = null;
      _isInitializedController.add(false);
    } catch (e) {
      debugPrint('Error disposing audio player: $e');
    }
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
