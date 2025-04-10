import 'package:flutter/foundation.dart';
import 'bird.dart';

class BirdList {
  final String id;
  final String name;
  final String description;
  final List<Bird> birds;
  final bool isCustom;
  final List<String>? regions;
  final List<String>? families;

  BirdList({
    required this.id,
    required this.name,
    required this.description,
    required this.birds,
    this.isCustom = false,
    this.regions,
    this.families,
  });

  // Predefined lists
  static List<BirdList> predefinedLists = [
    BirdList(
      id: 'northeast_warblers',
      name: 'Northeast Warblers',
      description: 'Common warblers found in the northeastern United States',
      birds: [
        Bird(
            speciesCode: 'yelwar',
            commonName: 'Yellow Warbler',
            scientificName: 'Setophaga petechia'),
        Bird(
            speciesCode: 'comyel',
            commonName: 'Common Yellowthroat',
            scientificName: 'Geothlypis trichas'),
        Bird(
            speciesCode: 'amered',
            commonName: 'American Redstart',
            scientificName: 'Setophaga ruticilla'),
        Bird(
            speciesCode: 'magwar',
            commonName: 'Magnolia Warbler',
            scientificName: 'Setophaga magnolia'),
        Bird(
            speciesCode: 'btbwar',
            commonName: 'Black-throated Blue Warbler',
            scientificName: 'Setophaga caerulescens'),
        Bird(
            speciesCode: 'btgwar',
            commonName: 'Black-throated Green Warbler',
            scientificName: 'Setophaga virens'),
        Bird(
            speciesCode: 'prawar',
            commonName: 'Prairie Warbler',
            scientificName: 'Setophaga discolor'),
        Bird(
            speciesCode: 'palmwa',
            commonName: 'Palm Warbler',
            scientificName: 'Setophaga palmarum'),
        Bird(
            speciesCode: 'myrwar',
            commonName: 'Myrtle Warbler',
            scientificName: 'Setophaga coronata'),
        Bird(
            speciesCode: 'ovenbi',
            commonName: 'Ovenbird',
            scientificName: 'Seiurus aurocapilla'),
      ],
      regions: ['US-ME', 'US-NH', 'US-VT', 'US-MA', 'US-CT', 'US-RI', 'US-NY'],
    ),
    BirdList(
      id: 'spring_migrants',
      name: 'Spring Migrants',
      description: 'Common birds seen during spring migration in the northeast',
      birds: [
        Bird(
            speciesCode: 'yelwar',
            commonName: 'Yellow Warbler',
            scientificName: 'Setophaga petechia'),
        Bird(
            speciesCode: 'comyel',
            commonName: 'Common Yellowthroat',
            scientificName: 'Geothlypis trichas'),
        Bird(
            speciesCode: 'amered',
            commonName: 'American Redstart',
            scientificName: 'Setophaga ruticilla'),
        Bird(
            speciesCode: 'magwar',
            commonName: 'Magnolia Warbler',
            scientificName: 'Setophaga magnolia'),
        Bird(
            speciesCode: 'btbwar',
            commonName: 'Black-throated Blue Warbler',
            scientificName: 'Setophaga caerulescens'),
        Bird(
            speciesCode: 'btgwar',
            commonName: 'Black-throated Green Warbler',
            scientificName: 'Setophaga virens'),
        Bird(
            speciesCode: 'prawar',
            commonName: 'Prairie Warbler',
            scientificName: 'Setophaga discolor'),
        Bird(
            speciesCode: 'palmwa',
            commonName: 'Palm Warbler',
            scientificName: 'Setophaga palmarum'),
        Bird(
            speciesCode: 'myrwar',
            commonName: 'Myrtle Warbler',
            scientificName: 'Setophaga coronata'),
        Bird(
            speciesCode: 'ovenbi',
            commonName: 'Ovenbird',
            scientificName: 'Seiurus aurocapilla'),
      ],
      regions: ['US-ME', 'US-NH', 'US-VT', 'US-MA', 'US-CT', 'US-RI', 'US-NY'],
    ),
    BirdList(
      id: 'common_thrushes',
      name: 'Common Thrushes',
      description: 'Common thrush species found in North America',
      birds: [
        Bird(
            speciesCode: 'amerob',
            commonName: 'American Robin',
            scientificName: 'Turdus migratorius'),
        Bird(
            speciesCode: 'herthr',
            commonName: 'Hermit Thrush',
            scientificName: 'Catharus guttatus'),
        Bird(
            speciesCode: 'swathr',
            commonName: 'Swainson\'s Thrush',
            scientificName: 'Catharus ustulatus'),
        Bird(
            speciesCode: 'woothr',
            commonName: 'Wood Thrush',
            scientificName: 'Hylocichla mustelina'),
        Bird(
            speciesCode: 'veery',
            commonName: 'Veery',
            scientificName: 'Catharus fuscescens'),
      ],
      families: ['Turdidae'],
    ),
  ];

  BirdList copyWith({
    String? id,
    String? name,
    String? description,
    List<Bird>? birds,
    bool? isCustom,
    List<String>? regions,
    List<String>? families,
  }) {
    return BirdList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      birds: birds ?? this.birds,
      isCustom: isCustom ?? this.isCustom,
      regions: regions ?? this.regions,
      families: families ?? this.families,
    );
  }
}
