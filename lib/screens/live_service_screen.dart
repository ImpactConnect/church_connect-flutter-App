import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LiveServiceScreen extends StatefulWidget {
  const LiveServiceScreen({super.key});

  @override
  State<LiveServiceScreen> createState() => _LiveServiceScreenState();
}

class _LiveServiceScreenState extends State<LiveServiceScreen> {
  late YoutubePlayerController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: 'jfKfPfyJRdk',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        isLive: true,
        forceHD: true,
        enableCaption: false,
        hideControls: false,
      ),
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          setState(() {
            _isLoading = false;
          });
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Live Service'),
          ),
          body: Column(
            children: [
              player,
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Welcome to our live service. Please ensure you have a stable internet connection for the best experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
