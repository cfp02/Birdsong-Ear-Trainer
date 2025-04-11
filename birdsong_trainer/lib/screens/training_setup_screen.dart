import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import '../models/bird_list.dart';
import '../providers/bird_list_provider.dart';
import '../providers/ebird_provider.dart';
import '../providers/training_provider.dart';
import 'training_screen.dart';

class TrainingSetupScreen extends ConsumerStatefulWidget {
  final BirdList birdList;

  const TrainingSetupScreen({
    super.key,
    required this.birdList,
  });

  @override
  ConsumerState<TrainingSetupScreen> createState() =>
      _TrainingSetupScreenState();
}

class _TrainingSetupScreenState extends ConsumerState<TrainingSetupScreen> {
  final Set<String> selectedBirdIds = {};

  @override
  void initState() {
    super.initState();
    selectedBirdIds.addAll(widget.birdList.birdIds);
  }

  @override
  Widget build(BuildContext context) {
    final birds = ref.watch(birdsInSelectedListProvider).when(
          data: (birds) => birds,
          loading: () => <Bird>[],
          error: (_, __) => <Bird>[],
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('Setup Training: ${widget.birdList.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: birds.length,
              itemBuilder: (context, index) {
                final bird = birds[index];
                return CheckboxListTile(
                  title: Text(bird.commonName),
                  subtitle: Text(bird.scientificName),
                  value: selectedBirdIds.contains(bird.speciesCode),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedBirdIds.add(bird.speciesCode);
                      } else {
                        selectedBirdIds.remove(bird.speciesCode);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                final selectedBirds = birds
                    .where((bird) => selectedBirdIds.contains(bird.speciesCode))
                    .toList();
                ref
                    .read(trainingSessionNotifierProvider.notifier)
                    .startLearningSession(
                      name: widget.birdList.name,
                      birds: selectedBirds,
                      isPreviewMode: true,
                    );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrainingScreen(),
                  ),
                );
              },
              child: const Text('Start Training'),
            ),
          ),
        ],
      ),
    );
  }
}
