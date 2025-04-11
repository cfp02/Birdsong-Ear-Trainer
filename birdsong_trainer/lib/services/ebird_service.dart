import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/bird.dart';

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

  Future<List<Map<String, dynamic>>> getBirdsByRegion(String regionCode) async {
    print('Fetching birds for region: $regionCode');
    final response = await http.get(
      Uri.parse('$_baseUrl/data/obs/$regionCode/recent'),
      headers: {
        'X-eBirdApiToken': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((bird) => {
                'comName': bird['comName'],
                'sciName': bird['sciName'],
                'speciesCode': bird['speciesCode'],
                'familyComName': bird['familyComName'],
                'order': bird['order'],
                'locName': bird['locName'],
              })
          .toList();
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
      final response = await _client.get(
        Uri.parse('$_baseUrl/ref/taxonomy/ebird?speciesCode=$speciesCode'),
        headers: {
          'X-eBirdApiToken': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data.first;
        }
        return null;
      } else {
        print('Failed to fetch bird data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in getBirdData: $e');
      return null;
    }
  }
}
