import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class XenoCantoService {
  static const String _baseUrl = 'https://xeno-canto.org/api/3/recordings';
  final String apiKey;
  final http.Client _client = http.Client();

  XenoCantoService({required this.apiKey});

  Future<List<Map<String, dynamic>>> getRecordingsForSpecies(
      String scientificName,
      {int limit = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?query=sp:"$scientificName"&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recordings = List<Map<String, dynamic>>.from(data['recordings']);
        return recordings.take(limit).toList();
      } else {
        throw Exception('Failed to load recordings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recordings for $scientificName: $e');
      return [];
    }
  }

  Future<String?> downloadRecording(String recordingId, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.mp3';
      final file = File(filePath);

      // Check if file already exists
      if (await file.exists()) {
        return filePath;
      }

      final response = await http.get(
        Uri.parse('https://xeno-canto.org/$recordingId/download'),
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Failed to download recording: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading recording $recordingId: $e');
      return null;
    }
  }

  Future<Map<String, List<String>>> prepareRecordingsForTraining(
    List<String> speciesCodes,
    List<String> scientificNames,
    int recordingsPerSpecies,
  ) async {
    final Map<String, List<String>> speciesRecordings = {};

    for (int i = 0; i < speciesCodes.length; i++) {
      final speciesCode = speciesCodes[i];
      final scientificName = scientificNames[i];
      final recordings = await getRecordingsForSpecies(
        scientificName,
        limit: recordingsPerSpecies,
      );

      final downloadedPaths = <String>[];
      for (final recording in recordings) {
        final recordingId = recording['id'].toString();
        final fileName = '${speciesCode}_${recordingId}';
        final path = await downloadRecording(recordingId, fileName);
        if (path != null) {
          downloadedPaths.add(path);
        }
      }

      if (downloadedPaths.isNotEmpty) {
        speciesRecordings[speciesCode] = downloadedPaths;
      }
    }

    return speciesRecordings;
  }
}

final xenoCantoServiceProvider = Provider<XenoCantoService>((ref) {
  final apiKey = const String.fromEnvironment('XENO_CANTO_API_KEY');
  return XenoCantoService(apiKey: apiKey);
});
