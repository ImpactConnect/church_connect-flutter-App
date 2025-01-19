import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../providers/radio_provider.dart';
import '../../models/radio_stream.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 180,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {},
                  tooltip: 'Refresh radio',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Radio',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/radio_header.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
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
                  ],
                ),
              ),
            ),
          ];
        },
        body: Consumer<RadioProvider>(
          builder: (context, radioProvider, child) {
            return Center(
              child: Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.radio,
                        size: 64,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      if (radioProvider.currentStream != null) ...[
                        Text(
                          radioProvider.currentStream!.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                      StreamBuilder<PlayerState>(
                        stream: radioProvider.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;

                          if (processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering) {
                            return Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 8),
                                Text(
                                  processingState == ProcessingState.loading
                                      ? 'Loading...'
                                      : 'Buffering...',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            );
                          }

                          if (radioProvider.error != null) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Error: ${radioProvider.error}',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          return Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  playing ?? false
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                ),
                                iconSize: 64.0,
                                onPressed: () {
                                  if (playing ?? false) {
                                    radioProvider.pause();
                                  } else {
                                    // Create a test stream if none exists
                                    if (radioProvider.currentStream == null) {
                                      final testStream = RadioStream(
                                        id: '1',
                                        title: 'Test Radio Stream',
                                        streamUrl: 'https://example.com/stream',
                                        isActive: true,
                                      );
                                      radioProvider.playStream(testStream);
                                    } else {
                                      radioProvider.playStream(radioProvider.currentStream!);
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.volume_down),
                                  Expanded(
                                    child: Slider(
                                      min: 0,
                                      max: 1,
                                      value: radioProvider.volume,
                                      onChanged: radioProvider.setVolume,
                                    ),
                                  ),
                                  const Icon(Icons.volume_up),
                                ],
                              ),
                              Text(
                                'Volume: ${(radioProvider.volume * 100).toInt()}%',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
