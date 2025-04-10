import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird_list.dart';
import '../providers/bird_list_provider.dart';
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
        title: const Text('Bird Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: birdLists.length,
              itemBuilder: (context, index) {
                final list = birdLists[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text(list.name),
                    subtitle: Text(list.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (list.isCustom) ...[
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
                        ElevatedButton(
                          onPressed: () {
                            ref.read(selectedBirdListProvider.notifier).state =
                                list;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TrainingSetupScreen(),
                              ),
                            );
                          },
                          child: const Text('Train'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => _showCreateListDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create New List'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
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
            const SizedBox(height: 16),
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
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                description: descriptionController.text,
                birdIds: [],
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

  void _showEditListDialog(BuildContext context, WidgetRef ref, BirdList list) {
    final nameController = TextEditingController(text: list.name);
    final descriptionController = TextEditingController(text: list.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'List Name'),
            ),
            const SizedBox(height: 16),
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
              final updatedList = BirdList(
                id: list.id,
                name: nameController.text,
                description: descriptionController.text,
                birdIds: list.birdIds,
                isCustom: true,
                regions: list.regions,
                families: list.families,
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
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, BirdList list) {
    showDialog(
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
              if (ref.read(selectedBirdListProvider)?.id == list.id) {
                ref.read(selectedBirdListProvider.notifier).state = null;
              }
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
