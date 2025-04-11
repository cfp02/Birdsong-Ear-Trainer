import 'package:flutter/foundation.dart';
import 'bird.dart';

class BirdList {
  final String id;
  final String name;
  final String description;
  final List<String> birdIds;
  final bool isCustom;
  final List<String>? regions;
  final List<String>? families;

  const BirdList({
    required this.id,
    required this.name,
    required this.description,
    required this.birdIds,
    this.isCustom = false,
    this.regions,
    this.families,
  });

  static const List<BirdList> predefinedLists = [
    BirdList(
      id: 'northeast_warblers',
      name: 'Northeast Warblers',
      description: 'Common warblers found in the northeastern United States',
      birdIds: [
        'btbwar', // Black-throated Blue Warbler
        'btgwar', // Black-throated Green Warbler
        'comyel', // Common Yellowthroat
        'ovenbi1', // Ovenbird
        'prawar', // Prairie Warbler
        'yelwar', // Yellow Warbler
        'nswwar', // Northern Waterthrush
        'mowar', // Mourning Warbler
        'amered', // American Redstart
        'magwar', // Magnolia Warbler
        'bawwar', // Black-and-white Warbler
        'blpwar', // Blackpoll Warbler
        'bnowa', // Bay-breasted Warbler
        'cawwar', // Canada Warbler
        'chswar', // Chestnut-sided Warbler
        'howwar', // Hooded Warbler
        'kewwar', // Kentucky Warbler
        'nopwar', // Northern Parula
        'pawwar', // Palm Warbler
        'prowar', // Prothonotary Warbler
        'whtwar', // Wilson's Warbler
        'yebcha', // Yellow-breasted Chat
        'yewwar', // Yellow-throated Warbler
      ],
      regions: ['US-MA', 'US-NY', 'US-VT', 'US-NH', 'US-ME'],
      families: ['Parulidae'],
    ),
    BirdList(
      id: 'spring_migrants',
      name: 'Spring Migrants',
      description: 'Birds that migrate through the northeast in spring',
      birdIds: [
        'bawwar', // Black-and-white Warbler
        'nswwar', // Northern Waterthrush
        'ovenbi1', // Ovenbird
        'comyel', // Common Yellowthroat
        'yelwar', // Yellow Warbler
        'btgwar', // Black-throated Green Warbler
        'btbwar', // Black-throated Blue Warbler
        'prawar', // Prairie Warbler
        'amered', // American Redstart
        'magwar', // Magnolia Warbler
      ],
      regions: ['US-MA', 'US-NY', 'US-VT', 'US-NH', 'US-ME'],
    ),
    BirdList(
      id: 'common_thrushes',
      name: 'Common Thrushes',
      description: 'Common thrush species found in the northeast',
      birdIds: [
        'amerob', // American Robin
        'herthr', // Hermit Thrush
        'swathr', // Swainson's Thrush
        'woothr', // Wood Thrush
        'veery', // Veery
      ],
      regions: ['US-MA', 'US-NY', 'US-VT', 'US-NH', 'US-ME'],
      families: ['Turdidae'],
    ),
  ];

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
}
