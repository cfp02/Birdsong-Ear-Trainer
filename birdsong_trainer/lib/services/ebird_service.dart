import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/bird.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EBirdService {
  static const String _baseUrl = 'https://api.ebird.org/v2';
  final String apiKey;
  final http.Client _client = http.Client();

  EBirdService({required this.apiKey}) {
    if (apiKey.isEmpty) {
      throw Exception('EBIRD_API_KEY not found in .env file');
    }
  }

  Future<List<Map<String, dynamic>>> getRegions() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/ref/region/list/subnational1/US'),
      headers: {
        'X-eBirdApiToken': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((region) => {
                'code': region['code'],
                'name': region['name'],
              })
          .toList();
    } else {
      throw Exception('Failed to load regions: ${response.statusCode}');
    }
  }

  Future<List<Bird>> getPredefinedBirds() async {
    // Return our predefined list of birds
    return [
      Bird(
        speciesCode: 'btbwar',
        commonName: 'Black-throated Blue Warbler',
        scientificName: 'Setophaga caerulescens',
        family: 'Parulidae',
        region: 'US',
        difficulty: 1,
      ),
      Bird(
        speciesCode: 'btgwar',
        commonName: 'Black-throated Green Warbler',
        scientificName: 'Setophaga virens',
        family: 'Parulidae',
        region: 'US',
        difficulty: 1,
      ),
      // Add more predefined birds here
    ];
  }

  Future<List<Map<String, dynamic>>> getBirdsByRegion({
    required String regionCode,
    String? speciesCode,
  }) async {
    // Use the taxonomy endpoint to get all possible birds for the region
    final url = Uri.parse('$_baseUrl/ref/taxonomy/ebird?fmt=json');
    final headers = {
      'X-eBirdApiToken': apiKey,
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Filter by region if specified
      if (regionCode.isNotEmpty) {
        // For now, we'll filter by US birds since the taxonomy endpoint doesn't support region filtering
        // In a real implementation, we'd need to maintain our own mapping of birds to regions
        return data
            .where((bird) => bird['category'] == 'species')
            .cast<Map<String, dynamic>>()
            .toList();
      }

      // Filter by species code if specified
      if (speciesCode != null) {
        return data
            .where((bird) => bird['speciesCode'] == speciesCode)
            .cast<Map<String, dynamic>>()
            .toList();
      }

      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load birds: ${response.statusCode}');
    }
  }

  Future<List<Bird>> getBirdsByFamily(String family) async {
    // This would require a different endpoint or filtering logic
    // as eBird doesn't directly support family-based queries
    throw UnimplementedError('Family-based queries not yet implemented');
  }

  Future<String?> getBirdAudioUrl(String speciesCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ref/taxonomy/ebird?speciesCode=$speciesCode'),
        headers: {
          'X-eBirdApiToken': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Note: This is a placeholder - the actual audio URL would need to be fetched
        // from a different source like Xeno-Canto or Macaulay Library
        return null;
      } else {
        throw Exception('Failed to fetch bird data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching audio URL: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBirdData(String speciesCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ref/taxonomy/ebird?fmt=json'),
        headers: {
          'X-eBirdApiToken': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final birdData = data.firstWhere(
          (bird) => bird['speciesCode'] == speciesCode,
          orElse: () => null,
        );

        if (birdData != null) {
          print('Fetched bird data for $speciesCode: $birdData');
          return {
            'speciesCode': birdData['speciesCode'] as String,
            'comName': birdData['comName'] as String,
            'sciName': birdData['sciName'] as String,
            'familyComName': birdData['familyComName'] as String?,
          };
        }
      }
      print('No data found for species code: $speciesCode');
      return null;
    } catch (e) {
      print('Error fetching bird data for $speciesCode: $e');
      return null;
    }
  }
}

final eBirdServiceProvider = Provider<EBirdService>((ref) {
  final apiKey = const String.fromEnvironment('EBIRD_API_KEY');
  return EBirdService(apiKey: apiKey);
});
