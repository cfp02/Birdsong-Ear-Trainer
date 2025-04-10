import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/bird.dart';

class EBirdService {
  static const String _baseUrl = 'https://api.ebird.org/v2';
  late final String _apiKey;

  EBirdService() {
    _apiKey = dotenv.env['EBIRD_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('EBIRD_API_KEY not found in .env file');
    }
  }

  Future<List<Map<String, dynamic>>> getRegions() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/ref/region/list/subnational1/US'),
      headers: {
        'X-eBirdApiToken': _apiKey,
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
        'X-eBirdApiToken': _apiKey,
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
}
