import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerButtons extends StatelessWidget {
  final AudioPlayer player;

  const PlayerButtons({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<bool>(
          stream: player.shuffleModeEnabledStream,
          builder: (context, snapshot) {
            return _shuffleButton(context, snapshot.data ?? false);
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) {
            return _previousButton();
          },
        ),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            return _playPauseButton(playerState);
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) {
            return _nextButton();
          },
        ),
        StreamBuilder<LoopMode>(
          stream: player.loopModeStream,
          builder: (context, snapshot) {
            return _repeatButton(context, snapshot.data ?? LoopMode.off);
          },
        ),
      ],
    );
  }

  Widget _shuffleButton(BuildContext context, bool isEnabled) {
    return IconButton(
      icon: isEnabled
          ? const Icon(Icons.shuffle, color: Colors.blue)
          : Icon(Icons.shuffle, color: Colors.grey.shade400),
      onPressed: () async {
        final enable = !isEnabled;
        if (enable) {
          await player.shuffle();
        }
        await player.setShuffleModeEnabled(enable);
      },
    );
  }

  Widget _previousButton() {
    return IconButton(
      icon: Icon(Icons.skip_previous, color: Colors.grey.shade400),
      onPressed: null,
    );
  }

  Widget _playPauseButton(PlayerState? playerState) {
    final processingState = playerState?.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: const CircularProgressIndicator(),
      );
    } else if (player.playing != true) {
      return IconButton(
        icon: const Icon(Icons.play_circle_fill),
        iconSize: 64.0,
        onPressed: player.play,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.pause_circle_filled),
        iconSize: 64.0,
        onPressed: player.pause,
      );
    }
  }

  Widget _nextButton() {
    return IconButton(
      icon: Icon(Icons.skip_next, color: Colors.grey.shade400),
      onPressed: null,
    );
  }

  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      Icon(Icons.repeat, color: Colors.grey.shade400),
      const Icon(Icons.repeat, color: Colors.blue),
      const Icon(Icons.repeat_one, color: Colors.blue),
    ];
    const cycleModes = [
      LoopMode.off,
      LoopMode.all,
      LoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);
    return IconButton(
      icon: icons[index],
      onPressed: () {
        player.setLoopMode(
            cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
      },
    );
  }
}
