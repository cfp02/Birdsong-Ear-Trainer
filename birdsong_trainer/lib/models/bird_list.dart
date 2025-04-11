import 'package:flutter/foundation.dart';
import 'bird.dart';

class BirdList {
  final String id;
  final String name;
  final String description;
  final List<String> birdIds;
  final bool isCustom;
  final List<String> regions;
  final List<String>? families;

  const BirdList({
    required this.id,
    required this.name,
    required this.description,
    required this.birdIds,
    this.isCustom = false,
    required this.regions,
    this.families,
  });

  BirdList copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? birdIds,
    bool? isCustom,
    List<String>? regions,
    List<String>? families,
  }) {
    return BirdList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      birdIds: birdIds ?? this.birdIds,
      isCustom: isCustom ?? this.isCustom,
      regions: regions ?? this.regions,
      families: families ?? this.families,
    );
  }

  static final List<BirdList> predefinedLists = [
    const BirdList(
      id: 'northeast_warblers',
      name: 'Northeast Warblers',
      description: 'Common warblers found in the northeastern United States',
      birdIds: [
        'btbwar', // Black-throated Blue Warbler
        'btgwar', // Black-throated Green Warbler
        'comyel', // Common Yellowthroat
        'nswwar', // Northern Waterthrush
        'ovenbi1', // Ovenbird
        'prawar', // Prairie Warbler
        'yelwar', // Yellow Warbler
      ],
      regions: ['US-MA', 'US-NY', 'US-CT', 'US-RI', 'US-NH', 'US-VT', 'US-ME'],
      families: ['Parulidae'],
    ),
    const BirdList(
      id: 'spring_migrants',
      name: 'Spring Migrants',
      description: 'Common birds seen during spring migration in the northeast',
      birdIds: [
        'bawwar', // Black-and-white Warbler
        'comyel', // Common Yellowthroat
        'ovenbi1', // Ovenbird
        'swathr', // Swainson's Thrush
        'whtspa', // White-throated Sparrow
        'yelwar', // Yellow Warbler
      ],
      regions: ['US-MA', 'US-NY', 'US-CT', 'US-RI', 'US-NH', 'US-VT', 'US-ME'],
    ),
    const BirdList(
      id: 'common_thrushes',
      name: 'Common Thrushes',
      description: 'Common thrush species found in North America',
      birdIds: [
        'amerob', // American Robin
        'herthr', // Hermit Thrush
        'swathr', // Swainson's Thrush
        'woothr', // Wood Thrush
      ],
      regions: ['US-MA', 'US-NY', 'US-CT', 'US-RI', 'US-NH', 'US-VT', 'US-ME'],
      families: ['Turdidae'],
    ),
  ];
}
