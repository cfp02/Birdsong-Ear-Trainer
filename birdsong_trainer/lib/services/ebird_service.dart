import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/bird.dart';

class EBirdService {
  static const String _baseUrl = 'https://api.ebird.org/v2';
  late String _apiKey;
  final http.Client _client;

  EBirdService({http.Client? client}) : _client = client ?? http.Client() {
    _apiKey = dotenv.env['EBIRD_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('EBIRD_API_KEY not found in environment variables');
    }
  }

  Future<List<Bird>> getBirdsByRegion(String regionCode) async {
    print('Fetching birds for region: $regionCode');
    final response = await _client.get(
      Uri.parse('$_baseUrl/data/obs/$regionCode/recent'),
      headers: {'X-eBirdApiToken': _apiKey},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Decoded data: $data');
      return data.map((json) => Bird.fromEBirdJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load birds from eBird: ${response.statusCode}');
    }
  }

  Future<List<Bird>> getBirdsByFamily(String family) async {
    // This would require a different endpoint or filtering logic
    // as eBird doesn't directly support family-based queries
    throw UnimplementedError('Family-based queries not yet implemented');
  }

  Future<List<String>> getRegions() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/ref/region/list/subnational1/US'),
      headers: {'X-eBirdApiToken': _apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((region) => region['code'] as String).toList();
    } else {
      throw Exception('Failed to load regions from eBird');
    }
  }
}
