import 'package:flutter/foundation.dart';

class BirdList {
  final String id;
  final String name;
  final String description;
  final List<String> birdIds;
  final bool isCustom;
  final List<String>? regions;
  final List<String>? families;

  BirdList({
    required this.id,
    required this.name,
    required this.description,
    required this.birdIds,
    this.isCustom = false,
    this.regions,
    this.families,
  });

  // Predefined lists
  static final List<BirdList> predefinedLists = [
    BirdList(
      id: 'northeast_warblers',
      name: 'Northeast Warblers',
      description: 'Common warblers found in the northeastern United States',
      birdIds: [
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
      regions: ['US-ME', 'US-NH', 'US-VT', 'US-MA', 'US-CT', 'US-RI', 'US-NY'],
      families: ['Parulidae'],
    ),
    BirdList(
      id: 'spring_migrants',
      name: 'Spring Migrants',
      description: 'Common birds seen during spring migration in the northeast',
      birdIds: [
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
      regions: ['US-ME', 'US-NH', 'US-VT', 'US-MA', 'US-CT', 'US-RI', 'US-NY'],
    ),
    BirdList(
      id: 'common_thrushes',
      name: 'Common Thrushes',
      description: 'Common thrush species found in North America',
      birdIds: [
        'amerob', // American Robin
        'herthr', // Hermit Thrush
        'swathr', // Swainson's Thrush
        'woothr', // Wood Thrush
        'veery', // Veery
      ],
      families: ['Turdidae'],
    ),
  ];
}
