import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import '../models/bird_list.dart';
import '../providers/bird_list_provider.dart';
import '../providers/ebird_provider.dart';
import 'training_setup_screen.dart';
import 'settings_screen.dart';
import 'bird_list_edit_screen.dart';

class BirdListSelectionScreen extends ConsumerWidget {
  const BirdListSelectionScreen({super.key});

  void _showEditDialog(BuildContext context, WidgetRef ref, BirdList list) {
    final nameController = TextEditingController(text: list.name);
    final descriptionController = TextEditingController(text: list.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bird List'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
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
              if (nameController.text.isNotEmpty) {
                final updatedList = list.copyWith(
                  name: nameController.text,
                  description: descriptionController.text,
                );
                ref
                    .read(birdListsProvider.notifier)
                    .updateCustomList(updatedList);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birdLists = ref.watch(birdListsProvider);
    final selectedList = ref.watch(selectedBirdListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bird List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: birdLists.length,
        itemBuilder: (context, index) {
          final list = birdLists[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(list.name),
              subtitle: Text(list.description),
              trailing: Radio<BirdList>(
                value: list,
                groupValue: selectedList,
                onChanged: (BirdList? value) {
                  if (value != null) {
                    ref.read(selectedBirdListProvider.notifier).state = value;
                  }
                },
              ),
              onTap: () {
                if (list.isCustom) {
                  _showEditDialog(context, ref, list);
                } else {
                  ref.read(selectedBirdListProvider.notifier).state = list;
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final nameController = TextEditingController();
          final descriptionController = TextEditingController();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Create New List'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
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
                    if (nameController.text.isNotEmpty) {
                      final newList = BirdList(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        description: descriptionController.text,
                        birdIds: const [],
                        isCustom: true,
                        regions: const ['US-MA'],
                      );
                      ref
                          .read(birdListsProvider.notifier)
                          .addCustomList(newList);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
