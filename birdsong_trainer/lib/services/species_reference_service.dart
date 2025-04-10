import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/bird.dart';

class SpeciesReferenceService {
  List<Map<String, dynamic>>? _speciesData;
  bool _isLoading = false;

  Future<void> loadSpeciesData() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/species_reference.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final decoded = json.decode(jsonString);
        if (decoded is List) {
          _speciesData = List<Map<String, dynamic>>.from(decoded);
        } else {
          print('Error: Expected a list of species data');
        }
      } else {
        print('Species reference file not found');
      }
    } catch (e) {
      print('Error loading species data: $e');
    } finally {
      _isLoading = false;
    }
  }

  List<Bird> getBirdsByFamily(String family) {
    if (_speciesData == null) return [];

    return _speciesData!
        .where((species) =>
            species['familyComName'] != null &&
            species['familyComName'] == family)
        .map((species) => Bird.fromJson(species))
        .toList();
  }

  List<Bird> getBirdsByRegion(String region) {
    if (_speciesData == null) return [];

    // Note: This is a simplified version. In reality, you'd need to
    // cross-reference with the eBird API to get actual sightings
    return _speciesData!.map((species) => Bird.fromJson(species)).toList();
  }

  Bird? getBirdBySpeciesCode(String speciesCode) {
    if (_speciesData == null) return null;

    try {
      final species = _speciesData!.firstWhere(
        (s) => s['speciesCode'] != null && s['speciesCode'] == speciesCode,
        orElse: () => {},
      );

      if (species.isEmpty) return null;
      return Bird.fromJson(species);
    } catch (e) {
      print('Error getting bird by species code: $e');
      return null;
    }
  }

  List<String> getFamilies() {
    if (_speciesData == null) return [];

    return _speciesData!
        .map((s) => s['familyComName'] as String?)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }
}

final speciesReferenceServiceProvider =
    Provider<SpeciesReferenceService>((ref) {
  return SpeciesReferenceService();
});
