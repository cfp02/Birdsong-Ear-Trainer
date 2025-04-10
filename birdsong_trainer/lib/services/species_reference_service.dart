import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/bird.dart';
import 'database_service.dart';

class SpeciesReferenceService {
  List<Map<String, dynamic>>? _speciesData;
  bool _isLoading = false;
  static const String _baseUrl = 'https://api.ebird.org/v2/ref/taxonomy/ebird';
  static const String _recentObsUrl = 'https://api.ebird.org/v2/data/obs';

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

  Future<List<Bird>> fetchSpeciesReference() async {
    final apiKey = dotenv.env['EBIRD_API_KEY'];
    if (apiKey == null) {
      throw Exception('EBIRD_API_KEY not found in .env file');
    }

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'X-eBirdApiToken': apiKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch species reference: ${response.statusCode}');
    }

    print('Response content type: ${response.headers['content-type']}');
    print(
        'First 500 characters of response: ${response.body.substring(0, 500)}');

    // Check if response is CSV
    if (response.headers['content-type']?.contains('text/csv') ?? false) {
      final csvData = response.body;
      final lines = csvData.split('\n');
      if (lines.isEmpty) return [];

      // Parse header
      final headers = lines[0].split(',');
      print('CSV Headers: $headers');

      final speciesCodeIndex = headers.indexOf('SPECIES_CODE');
      final commonNameIndex = headers.indexOf('COMMON_NAME');
      final scientificNameIndex = headers.indexOf('SCIENTIFIC_NAME');
      final familyComNameIndex = headers.indexOf('FAMILY_COM_NAME');

      print(
          'Column indices: species=$speciesCodeIndex, common=$commonNameIndex, scientific=$scientificNameIndex, family=$familyComNameIndex');

      if (speciesCodeIndex == -1 ||
          commonNameIndex == -1 ||
          scientificNameIndex == -1) {
        throw Exception(
            'Required columns not found in CSV response. Headers: $headers');
      }

      final List<Bird> birds = [];
      for (var i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;

        final values = lines[i].split(',');
        if (values.length < headers.length) {
          print('Skipping line $i: insufficient values');
          continue;
        }

        birds.add(Bird(
          speciesCode: values[speciesCodeIndex],
          commonName: values[commonNameIndex],
          scientificName: values[scientificNameIndex],
          family: familyComNameIndex != -1 ? values[familyComNameIndex] : null,
          region: null,
          difficulty: 1,
        ));

        if (i < 5) {
          print(
              'Parsed bird $i: ${values[commonNameIndex]} (${values[speciesCodeIndex]})');
        }
      }

      return birds;
    }

    // Handle JSON response
    final List<dynamic> data = json.decode(response.body);
    final List<Bird> birds = [];

    for (var item in data) {
      birds.add(Bird(
        speciesCode: item['speciesCode'],
        commonName: item['comName'],
        scientificName: item['sciName'],
        family: item['familyComName'],
        region: null,
        difficulty: 1,
      ));
    }

    return birds;
  }

  Future<void> storeSpeciesReference() async {
    try {
      final birds = await fetchSpeciesReference();
      final db = DatabaseService.instance;

      for (var bird in birds) {
        await db.insertBird(bird);
      }

      print('Successfully stored ${birds.length} bird species in the database');
    } catch (e) {
      print('Error storing species reference: $e');
      rethrow;
    }
  }

  Future<List<Bird>> fetchBirdsByRegion(String regionCode) async {
    final apiKey = dotenv.env['EBIRD_API_KEY'];
    if (apiKey == null) {
      throw Exception('EBIRD_API_KEY not found in .env file');
    }

    final response = await http.get(
      Uri.parse('$_recentObsUrl/$regionCode/recent'),
      headers: {
        'X-eBirdApiToken': apiKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch birds for region: ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body);
    final List<Bird> birds = [];

    for (var item in data) {
      birds.add(Bird(
        speciesCode: item['speciesCode'],
        commonName: item['comName'],
        scientificName: item['sciName'],
        family: item['familyComName'],
        region: regionCode,
        difficulty: 1,
      ));
    }

    return birds;
  }

  Future<void> storeBirdsByRegion(String regionCode) async {
    try {
      final birds = await fetchBirdsByRegion(regionCode);
      final db = DatabaseService.instance;

      for (var bird in birds) {
        await db.insertBird(bird);
      }

      print('Successfully stored ${birds.length} birds for region $regionCode');
    } catch (e) {
      print('Error storing birds for region $regionCode: $e');
      rethrow;
    }
  }
}

final speciesReferenceServiceProvider =
    Provider<SpeciesReferenceService>((ref) {
  return SpeciesReferenceService();
});
