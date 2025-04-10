import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import '../models/bird_list.dart';
import '../providers/bird_list_provider.dart';
import '../providers/ebird_provider.dart';
import 'training_setup_screen.dart';
import 'settings_screen.dart';

class BirdListSelectionScreen extends ConsumerWidget {
  const BirdListSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birdLists = ref.watch(birdListsProvider);
    final selectedList = ref.watch(selectedBirdListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bird List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateListDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Predefined Lists Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Predefined Lists',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: BirdList.predefinedLists.length,
              itemBuilder: (context, index) {
                final list = BirdList.predefinedLists[index];
                return ListTile(
                  title: Text(list.name),
                  subtitle: Text(list.description),
                  onTap: () {
                    ref.read(selectedBirdListProvider.notifier).state = list;
                  },
                );
              },
            ),
          ),
          const Divider(),
          // Custom Lists Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Custom Lists',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: birdLists.length,
              itemBuilder: (context, index) {
                final list = birdLists[index];
                return ListTile(
                  title: Text(list.name),
                  subtitle: Text('${list.birds.length} birds'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showEditListDialog(context, ref, list),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _showDeleteConfirmation(context, ref, list),
                      ),
                    ],
                  ),
                  onTap: () {
                    ref.read(selectedBirdListProvider.notifier).state = list;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateListDialog(
      BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'List Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newList = BirdList(
                id: nameController.text.toLowerCase().replaceAll(' ', '_'),
                name: nameController.text,
                description: descriptionController.text,
                birds: [],
                isCustom: true,
              );
              ref.read(birdListsProvider.notifier).addCustomList(newList);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditListDialog(
      BuildContext context, WidgetRef ref, BirdList list) async {
    final nameController = TextEditingController(text: list.name);
    final descriptionController = TextEditingController(text: list.description);
    final regionController =
        TextEditingController(text: list.regions?.first ?? 'US-MA');
    final ebirdService = ref.read(ebirdServiceProvider);
    final availableBirds = <Bird>[];

    // Fetch available birds for the region
    try {
      final regionBirds =
          await ebirdService.getBirdsByRegion(regionController.text);
      for (var birdData in regionBirds) {
        try {
          final bird = Bird.fromJson(birdData);
          availableBirds.add(bird);
        } catch (e) {
          print('Error converting bird data: $e');
        }
      }
    } catch (e) {
      print('Error fetching birds: $e');
    }

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit List'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'List Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: regionController,
                  decoration:
                      const InputDecoration(labelText: 'Region (e.g., US-MA)'),
                ),
                const SizedBox(height: 16),
                const Text('Birds in List:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...list.birds
                    .map((bird) => ListTile(
                          title: Text(bird.commonName),
                          subtitle: Text(bird.scientificName),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
                                list.birds.remove(bird);
                              });
                            },
                          ),
                        ))
                    .toList(),
                const SizedBox(height: 16),
                const Text('Available Birds:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...availableBirds
                    .where((bird) => !list.birds.contains(bird))
                    .map((bird) => ListTile(
                          title: Text(bird.commonName),
                          subtitle: Text(bird.scientificName),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                list.birds.add(bird);
                              });
                            },
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedList = list.copyWith(
                  name: nameController.text,
                  description: descriptionController.text,
                  regions: [regionController.text],
                );
                ref
                    .read(birdListsProvider.notifier)
                    .updateCustomList(updatedList);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, BirdList list) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text('Are you sure you want to delete "${list.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(birdListsProvider.notifier).removeCustomList(list.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
