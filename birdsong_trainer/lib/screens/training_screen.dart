import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_player_provider.dart';
import '../providers/bird_list_provider.dart';
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
    final birds = await ref.read(birdsInSelectedListProvider.future);
    if (birds.isNotEmpty) {
      setState(() {
        _currentBird = birds[0]; // For now, just use the first bird
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training'),
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
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
