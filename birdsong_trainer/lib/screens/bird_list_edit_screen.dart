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
  late TextEditingController searchController;
  List<Bird> availableBirds = [];
  List<String> selectedBirdIds = [];
  bool isLoading = true;
  String? selectedFamily;
  String searchText = '';
  List<Map<String, dynamic>> regions = [];
  String? selectedRegion;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.list.name);
    descriptionController =
        TextEditingController(text: widget.list.description);
    searchController = TextEditingController();
    selectedBirdIds = List.from(widget.list.birdIds);
    selectedRegion = widget.list.regions?.firstOrNull ?? 'US-MA';
    _loadRegions();
    _loadBirds();
  }

  Future<void> _loadRegions() async {
    try {
      final ebirdService = ref.read(ebirdServiceProvider);
      final loadedRegions = await ebirdService.getRegions();
      setState(() {
        regions = loadedRegions;
      });
    } catch (e) {
      print('Error loading regions: $e');
    }
  }

  Future<void> _loadBirds() async {
    if (selectedRegion == null) return;

    setState(() => isLoading = true);
    try {
      final ebirdService = ref.read(ebirdServiceProvider);
      final regionBirds = await ebirdService.getBirdsByRegion(
        regionCode: selectedRegion!,
      );

      final List<Bird> loadedBirds = [];
      for (final birdData in regionBirds) {
        try {
          final bird = Bird.fromEBirdJson(birdData);
          loadedBirds.add(bird);
        } catch (e) {
          print('Error parsing bird data: $e');
          print('Problematic bird data: $birdData');
        }
      }

      print('Loaded ${loadedBirds.length} birds from region $selectedRegion');
      print('Selected bird IDs: $selectedBirdIds');

      // Check which selected birds are not found in the loaded birds
      final loadedBirdIds = loadedBirds.map((b) => b.speciesCode).toSet();
      final missingBirdIds =
          selectedBirdIds.where((id) => !loadedBirdIds.contains(id)).toList();
      if (missingBirdIds.isNotEmpty) {
        print(
            'Warning: Some selected birds not found in region: $missingBirdIds');
      }

      setState(() {
        availableBirds = loadedBirds;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching birds: $e');
      setState(() => isLoading = false);
    }
  }

  List<Bird> getFilteredBirds() {
    return availableBirds.where((bird) {
      final matchesSearch = searchText.isEmpty ||
          bird.commonName.toLowerCase().contains(searchText.toLowerCase()) ||
          bird.scientificName.toLowerCase().contains(searchText.toLowerCase());
      final matchesFamily = selectedFamily == null ||
          bird.family?.toLowerCase() == selectedFamily?.toLowerCase();
      return matchesSearch && matchesFamily;
    }).toList();
  }

  List<String> getUniqueFamilies() {
    final families = <String>{};
    for (final bird in availableBirds) {
      if (bird.family != null) {
        families.add(bird.family!);
      }
    }
    final sortedFamilies = families.toList()..sort();
    return sortedFamilies;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    searchController.dispose();
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
                regions: [selectedRegion ?? 'US-MA'],
                birdIds: selectedBirdIds,
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
                      child: DropdownButtonFormField<String>(
                        value: selectedRegion,
                        decoration: const InputDecoration(
                          labelText: 'Region',
                        ),
                        items: regions.map((region) {
                          return DropdownMenuItem<String>(
                            value: region['code'],
                            child: Text(region['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRegion = value;
                          });
                          _loadBirds();
                        },
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
                          itemCount: selectedBirdIds.length,
                          itemBuilder: (context, index) {
                            final birdId = selectedBirdIds[index];
                            final bird = availableBirds.firstWhere(
                              (b) => b.speciesCode == birdId,
                              orElse: () => Bird(
                                speciesCode: birdId,
                                commonName: 'Unknown',
                                scientificName: 'Unknown',
                              ),
                            );
                            return ListTile(
                              title: Text(bird.commonName),
                              subtitle: Text(bird.scientificName),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    selectedBirdIds.remove(birdId);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        // Available Birds Tab
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: searchController,
                                    decoration: const InputDecoration(
                                      labelText: 'Search birds',
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchText = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: selectedFamily,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Filter by family',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('All families'),
                                      ),
                                      ...getUniqueFamilies().map((family) {
                                        return DropdownMenuItem<String>(
                                          value: family,
                                          child: Text(family ?? 'Unknown'),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedFamily = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : ListView.builder(
                                      itemCount: getFilteredBirds().length,
                                      itemBuilder: (context, index) {
                                        final bird = getFilteredBirds()[index];
                                        final isInList = selectedBirdIds
                                            .contains(bird.speciesCode);
                                        return ListTile(
                                          title: Text(bird.commonName),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(bird.scientificName),
                                              if (bird.family != null)
                                                Text(
                                                  bird.family!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                            ],
                                          ),
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
                                                      selectedBirdIds.add(
                                                          bird.speciesCode);
                                                    });
                                                  },
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
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
