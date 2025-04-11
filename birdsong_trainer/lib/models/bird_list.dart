import 'package:flutter/foundation.dart';
import 'bird.dart';

class BirdList {
  final String id;
  final String name;
  final String description;
  final List<String> birdIds;
  final List<String>? regions;
  final List<String>? families;

  const BirdList({
    required this.id,
    required this.name,
    required this.description,
    required this.birdIds,
    this.regions,
    this.families,
  });

  BirdList copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? birdIds,
    List<String>? regions,
    List<String>? families,
  }) {
    return BirdList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      birdIds: birdIds ?? this.birdIds,
      regions: regions ?? this.regions,
      families: families ?? this.families,
    );
  }
}
