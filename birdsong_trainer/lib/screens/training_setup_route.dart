import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bird_list_provider.dart';
import '../providers/ebird_provider.dart';
import 'training_screen.dart';

class TrainingSetupRoute extends ConsumerWidget {
  const TrainingSetupRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedList = ref.watch(selectedBirdListProvider);
    final birdsAsync = ref.watch(birdsInSelectedListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedList == null)
              const Text('Please select a bird list first')
            else ...[
              Text('Selected List: ${selectedList.name}'),
              const SizedBox(height: 16),
              birdsAsync.when(
                data: (birds) {
                  if (birds.isEmpty) {
                    return const Text('No birds found in this list');
                  }
                  return Column(
                    children: [
                      Text('${birds.length} birds available'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrainingScreen(),
                            ),
                          );
                        },
                        child: const Text('Start Training'),
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
