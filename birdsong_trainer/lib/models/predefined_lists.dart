import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import 'bird.dart';

class PredefinedList {
  final String name;
  final String description;
  final List<String> speciesCodes;
  final List<String> regions;
  final String? family;

  const PredefinedList({
    required this.name,
    required this.description,
    required this.speciesCodes,
    this.regions = const [],
    this.family,
  });
}

// Predefined lists for common bird groups
final predefinedLists = [
  // Warblers
  PredefinedList(
    name: 'Northeast Warblers',
    description: 'Common warblers found in the northeastern United States',
    speciesCodes: [
      'yelwar', // Yellow Warbler
      'comyel', // Common Yellowthroat
      'amered', // American Redstart
      'magwar', // Magnolia Warbler
      'btbwar', // Black-throated Blue Warbler
      'btgwar', // Black-throated Green Warbler
      'prawar', // Prairie Warbler
      'palmwa', // Palm Warbler
      'myrwar', // Myrtle Warbler
      'ovenbi', // Ovenbird
    ],
    regions: ['US-ME', 'US-MA', 'US-NY'],
    family: 'Wood-Warblers',
  ),

  // Thrushes
  PredefinedList(
    name: 'Common Thrushes',
    description: 'Common thrush species found in North America',
    speciesCodes: [
      'amerob', // American Robin
      'herthr', // Hermit Thrush
      'swathr', // Swainson's Thrush
      'woothr', // Wood Thrush
      'veery', // Veery
    ],
    family: 'Thrushes',
  ),

  // Spring Migrants
  PredefinedList(
    name: 'Spring Migrants',
    description: 'Common birds seen during spring migration in the northeast',
    speciesCodes: [
      'yelwar', // Yellow Warbler
      'comyel', // Common Yellowthroat
      'amerob', // American Robin
      'herthr', // Hermit Thrush
      'swathr', // Swainson's Thrush
      'woothr', // Wood Thrush
      'veery', // Veery
      'bkbwar', // Black-and-white Warbler
      'nswa', // Northern Parula
      'blujay', // Blue Jay
    ],
    regions: ['US-ME', 'US-MA', 'US-NY'],
  ),

  // Common Backyard Birds
  PredefinedList(
    name: 'Backyard Birds',
    description: 'Common birds found in backyards across North America',
    speciesCodes: [
      'amerob', // American Robin
      'blujay', // Blue Jay
      'carwre', // Carolina Wren
      'chispa', // Chipping Sparrow
      'dowwoo', // Downy Woodpecker
      'houspa', // House Sparrow
      'norcar', // Northern Cardinal
      'tuftit', // Tufted Titmouse
      'whbnut', // White-breasted Nuthatch
    ],
  ),
];

// Provider for managing predefined lists
final predefinedListsProvider = FutureProvider<List<Bird>>((ref) async {
  final db = DatabaseService.instance;
  final allBirds = await db.getBirds();

  // Get all species codes from predefined lists
  final allSpeciesCodes =
      predefinedLists.expand((list) => list.speciesCodes).toSet().toList();

  // Filter birds that match any of the species codes
  return allBirds
      .where((bird) => allSpeciesCodes.contains(bird.speciesCode))
      .toList();
});

// Provider for a specific predefined list
final predefinedListProvider =
    FutureProvider.family<List<Bird>, String>((ref, listName) async {
  final db = DatabaseService.instance;
  final list = predefinedLists.firstWhere((l) => l.name == listName);

  // Get all birds that match the species codes in this list
  final birds = await db.getBirds(
    region: list.regions.isNotEmpty ? list.regions.first : null,
    family: list.family,
  );

  return birds
      .where((bird) => list.speciesCodes.contains(bird.speciesCode))
      .toList();
});
