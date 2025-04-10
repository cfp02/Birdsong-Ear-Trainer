import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import '../models/bird_list.dart';
import '../providers/bird_list_provider.dart';
import '../providers/ebird_provider.dart';

class BirdListEditScreen extends ConsumerStatefulWidget {
  final BirdList list;

  const BirdListEditScreen({super.key, required this.list});

  @override
  ConsumerState<BirdListEditScreen> createState() => _BirdListEditScreenState();
}

class _BirdListEditScreenState extends ConsumerState<BirdListEditScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController regionController;
  List<Bird> availableBirds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.list.name);
    descriptionController =
        TextEditingController(text: widget.list.description);
    regionController =
        TextEditingController(text: widget.list.regions?.first ?? 'US-MA');
    _loadBirds();
  }

  Future<void> _loadBirds() async {
    setState(() => isLoading = true);
    try {
      final ebirdService = ref.read(ebirdServiceProvider);
      final regionBirds =
          await ebirdService.getBirdsByRegion(regionController.text);
      setState(() {
        availableBirds = regionBirds
            .map((birdData) => Bird.fromJson(birdData))
            .where((bird) => bird != null)
            .cast<Bird>()
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching birds: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bird List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final updatedList = widget.list.copyWith(
                name: nameController.text,
                description: descriptionController.text,
                regions: [regionController.text],
              );
              ref
                  .read(birdListsProvider.notifier)
                  .updateCustomList(updatedList);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'List Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: regionController,
                        decoration: const InputDecoration(
                            labelText: 'Region (e.g., US-MA)'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadBirds,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Birds in List'),
                      Tab(text: 'Available Birds'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Birds in List Tab
                        ListView.builder(
                          itemCount: widget.list.birds.length,
                          itemBuilder: (context, index) {
                            final bird = widget.list.birds[index];
                            return ListTile(
                              title: Text(bird.commonName),
                              subtitle: Text(bird.scientificName),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    widget.list.birds.remove(bird);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        // Available Birds Tab
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: availableBirds.length,
                                itemBuilder: (context, index) {
                                  final bird = availableBirds[index];
                                  final isInList =
                                      widget.list.birds.contains(bird);
                                  return ListTile(
                                    title: Text(bird.commonName),
                                    subtitle: Text(bird.scientificName),
                                    trailing: IconButton(
                                      icon: Icon(
                                        isInList
                                            ? Icons.check_circle
                                            : Icons.add_circle_outline,
                                      ),
                                      onPressed: isInList
                                          ? null
                                          : () {
                                              setState(() {
                                                widget.list.birds.add(bird);
                                              });
                                            },
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
