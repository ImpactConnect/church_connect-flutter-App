import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/radio_stream.dart';
import '../services/radio_service.dart';

class RadioProvider extends ChangeNotifier {
  final RadioService _radioService = RadioService();
  bool _isLoading = false;
  String? _error;
  double _volume = 1.0;

  RadioProvider() {
    _init();
  }

  void _init() async {
    try {
      await _radioService.setVolume(_volume);
    } catch (e) {
      _error = 'Failed to initialize volume: $e';
      notifyListeners();
    }
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  RadioStream? get currentStream => _radioService.currentStream;
  double get volume => _volume;
  Stream<PlayerState> get playerStateStream => _radioService.playerStateStream;

  Future<void> playStream(RadioStream stream) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      await _radioService.playStream(stream);
    } catch (e) {
      _error = 'Failed to play stream: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _radioService.pause();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to pause stream: $e';
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _radioService.stop();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to stop stream: $e';
      notifyListeners();
    }
  }

  Future<void> setVolume(double value) async {
    try {
      _volume = value;
      await _radioService.setVolume(value);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to set volume: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _radioService.dispose();
    super.dispose();
  }
}
