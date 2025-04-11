import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_player_provider.dart';
import '../providers/bird_list_provider.dart';
import '../providers/training_provider.dart';
import '../models/bird.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  Bird? _currentBird;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadNextBird();
  }

  Future<void> _loadNextBird() async {
    final session = ref.read(trainingSessionNotifierProvider);
    if (session != null && session.birds.isNotEmpty) {
      setState(() {
        _currentBird = session.currentBird;
      });
    }
  }

  Future<void> _playBirdAudio() async {
    if (_currentBird != null) {
      setState(() => _isPlaying = true);
      await ref
          .read(audioPlayerProvider.notifier)
          .playBirdAudio(_currentBird!.speciesCode);
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(trainingSessionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training'),
        actions: [
          if (session != null) ...[
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: session.canGoPrevious
                  ? () {
                      ref
                          .read(trainingSessionNotifierProvider.notifier)
                          .previousBird();
                      _loadNextBird();
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: session.canGoNext
                  ? () {
                      ref
                          .read(trainingSessionNotifierProvider.notifier)
                          .nextBird();
                      _loadNextBird();
                    }
                  : null,
            ),
          ],
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentBird != null) ...[
              Text(
                _currentBird!.commonName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                _currentBird!.scientificName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isPlaying ? null : _playBirdAudio,
                child: Text(_isPlaying ? 'Playing...' : 'Play Sound'),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: session?.progress ?? 0,
              ),
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
