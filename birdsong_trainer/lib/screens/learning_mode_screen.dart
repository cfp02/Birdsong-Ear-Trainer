import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import '../models/training_session.dart';
import '../providers/training_provider.dart';
import '../providers/audio_player_provider.dart';

class LearningModeScreen extends ConsumerWidget {
  const LearningModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentTrainingSessionProvider);
    final audioPlayer = ref.watch(audioPlayerProvider);

    if (session == null) {
      return const Scaffold(
        body: Center(
          child: Text('No active training session'),
        ),
      );
    }

    final currentBird = session.currentBird;
    final isPreviewMode = session.mode == TrainingMode.learningPreview;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(trainingSessionNotifierProvider.notifier).endSession();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: session.progress,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isPreviewMode) ...[
                    Text(
                      currentBird.commonName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentBird.scientificName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 32),
                    IconButton(
                      icon: Icon(
                        audioPlayer.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 64,
                      ),
                      onPressed: () {
                        if (audioPlayer.isPlaying) {
                          ref.read(audioPlayerProvider.notifier).pause();
                        } else {
                          ref
                              .read(audioPlayerProvider.notifier)
                              .playBirdSong(currentBird.speciesCode);
                        }
                      },
                    ),
                  ] else ...[
                    IconButton(
                      icon: Icon(
                        audioPlayer.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 64,
                      ),
                      onPressed: () {
                        if (audioPlayer.isPlaying) {
                          ref.read(audioPlayerProvider.notifier).pause();
                        } else {
                          ref
                              .read(audioPlayerProvider.notifier)
                              .playBirdSong(currentBird.speciesCode);
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      currentBird.commonName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentBird.scientificName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: session.canGoPrevious
                            ? () {
                                ref
                                    .read(trainingSessionNotifierProvider
                                        .notifier)
                                    .previousBird();
                              }
                            : null,
                      ),
                      const SizedBox(width: 32),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: session.canGoNext
                            ? () {
                                ref
                                    .read(trainingSessionNotifierProvider
                                        .notifier)
                                    .nextBird();
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('I know this bird'),
                    value: session.isBirdLearned(currentBird),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(trainingSessionNotifierProvider.notifier)
                            .markBirdAsLearned(currentBird, value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
