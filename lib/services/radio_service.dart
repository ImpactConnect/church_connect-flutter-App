import 'package:just_audio/just_audio.dart';
import '../models/radio_stream.dart';

class RadioService {
  final AudioPlayer _player = AudioPlayer();
  RadioStream? _currentStream;

  // Getters
  RadioStream? get currentStream => _currentStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  // Methods
  Future<void> playStream(RadioStream stream) async {
    _currentStream = stream;
    await _player.setUrl(stream.streamUrl);
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  void dispose() {
    _player.dispose();
  }
}
