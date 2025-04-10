import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<void> downloadSpeciesReference() async {
  final apiKey = const String.fromEnvironment('EBIRD_API_KEY');
  if (apiKey.isEmpty) {
    print('Error: EBIRD_API_KEY environment variable not set');
    print('Please run with: flutter run --dart-define=EBIRD_API_KEY=your_key');
    return;
  }

  try {
    print('Downloading species reference data...');
    final response = await http.get(
      Uri.parse('https://api.ebird.org/v2/ref/taxonomy/ebird'),
      headers: {'X-eBirdApiToken': apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is! List) {
        print('Error: Expected a list of species data');
        return;
      }

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/species_reference.json');

      // Write the data to a file
      await file.writeAsString(json.encode(data));
      print('Species reference data saved to: ${file.path}');
      print('Downloaded ${data.length} species');
    } else {
      print('Error downloading species reference: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
