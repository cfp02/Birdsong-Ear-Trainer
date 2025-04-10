import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import '../models/region.dart';
import '../providers/ebird_provider.dart';

class BirdSelectionScreen extends ConsumerWidget {
  const BirdSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regionsAsync = ref.watch(regionsProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);
    final birdsAsync = ref.watch(birdsProvider(selectedRegion));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Birds'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: regionsAsync.when(
              data: (regions) => DropdownButtonFormField<String>(
                value: selectedRegion,
                decoration: const InputDecoration(
                  labelText: 'Select Region',
                  border: OutlineInputBorder(),
                ),
                items: regions.map((region) {
                  return DropdownMenuItem<String>(
                    value: region.code,
                    child: Text(region.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    print('Selected region: $value');
                    ref.read(selectedRegionProvider.notifier).state = value;
                  }
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading regions: $error'),
            ),
          ),
          Expanded(
            child: birdsAsync.when(
              data: (birds) {
                print('Received ${birds.length} birds');
                return birds.isEmpty
                    ? const Center(
                        child: Text('Select a region to see birds'),
                      )
                    : ListView.builder(
                        itemCount: birds.length,
                        itemBuilder: (context, index) {
                          final bird = birds[index];
                          return ListTile(
                            title: Text(bird.commonName),
                            subtitle: Text(bird.scientificName),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Added ${bird.commonName} to training list'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) {
                print('Error loading birds: $error');
                print('Stack trace: $stack');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.refresh(birdsProvider(selectedRegion));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
