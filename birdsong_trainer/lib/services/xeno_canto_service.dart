import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class XenoCantoService {
  static const String _baseUrl = 'https://xeno-canto.org/api/3';
  final String apiKey;
  final http.Client _client = http.Client();

  XenoCantoService({required this.apiKey}) {
    if (apiKey.isEmpty) {
      throw Exception('XENO_CANTO_API_KEY not found in .env file');
    }
  }

  Future<String?> getBirdAudioUrl(String speciesCode) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$_baseUrl/recordings?query=sp:"$speciesCode"+grp:birds&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['recordings'] != null && data['recordings'].isNotEmpty) {
          // Get the first recording with quality A or B
          final recording = data['recordings'].firstWhere(
            (rec) => rec['q'] == 'A' || rec['q'] == 'B',
            orElse: () => data['recordings'][0],
          );
          return 'https:${recording['file']}';
        }
      } else {
        print('Failed to fetch audio URL: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print('Error in getBirdAudioUrl: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> searchRecordings({
    String? speciesCode,
    String? commonName,
    String? type = 'song',
    String? quality = 'A',
    int limit = 1,
  }) async {
    try {
      String query = '';
      if (speciesCode != null) {
        query += 'sp:$speciesCode ';
      }
      if (commonName != null) {
        query += 'en:"$commonName" ';
      }
      if (type != null) {
        query += 'type:$type ';
      }
      if (quality != null) {
        query += 'q:$quality ';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl?query=$query&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['recordings'] != null) {
          return List<Map<String, dynamic>>.from(data['recordings'])
              .take(limit)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching Xeno-Canto recordings: $e');
      return [];
    }
  }
}
