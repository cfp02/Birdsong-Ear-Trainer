import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import '../providers/bird_list_provider.dart';
import '../providers/ebird_provider.dart';

class TrainingSetupScreen extends ConsumerWidget {
  const TrainingSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedList = ref.watch(selectedBirdListProvider);
    final birdsAsync = ref.watch(birdsInSelectedListProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Setup'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected List: ${selectedList?.name ?? "None"}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Region: $selectedRegion',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selected Birds',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: birdsAsync.when(
              data: (birds) => ListView.builder(
                itemCount: birds.length,
                itemBuilder: (context, index) {
                  final bird = birds[index];
                  return Dismissible(
                    key: Key(bird.speciesCode),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      // TODO: Implement bird removal
                    },
                    child: ListTile(
                      title: Text(bird.commonName),
                      subtitle: Text(bird.scientificName),
                      trailing: const Icon(Icons.drag_handle),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading birds: $error'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to bird selection screen
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add More Birds'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to training screen
                  },
                  child: const Text('Start Training'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
