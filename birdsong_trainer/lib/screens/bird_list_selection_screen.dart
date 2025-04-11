import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import '../models/bird_list.dart';
import '../providers/bird_list_provider.dart';
import 'bird_list_edit_screen.dart';
import 'training_setup_screen.dart';

class BirdListSelectionScreen extends ConsumerWidget {
  const BirdListSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birdLists = ref.watch(birdListsProvider);
    final selectedList = ref.watch(selectedBirdListProvider);
    final birdsInList = ref.watch(birdsInSelectedListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bird Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateListDialog(context, ref),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: birdLists.length,
        itemBuilder: (context, index) {
          final list = birdLists[index];
          return ListTile(
            title: Text(list.name),
            subtitle: Text(list.description ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    // Set the selected list and navigate to training setup
                    ref.read(selectedBirdListProvider.notifier).state = list;
                    Navigator.pushNamed(
                      context,
                      '/training-setup',
                      arguments: list,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/edit-list',
                    arguments: list,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      _showDeleteConfirmationDialog(context, ref, list),
                ),
              ],
            ),
            onTap: () => Navigator.pushNamed(
              context,
              '/edit-list',
              arguments: list,
            ),
          );
        },
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
              if (nameController.text.isNotEmpty) {
                ref.read(birdListsProvider.notifier).addCustomList(
                      BirdList(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        description: descriptionController.text,
                        birdIds: [],
                        isCustom: true,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    BirdList list,
  ) {
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
              ref.read(birdListsProvider.notifier).removeCustomList(list);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
