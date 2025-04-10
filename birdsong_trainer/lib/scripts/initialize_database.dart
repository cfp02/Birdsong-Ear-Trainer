import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/species_reference_service.dart';

Future<void> main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  final service = SpeciesReferenceService();

  try {
    print('Fetching and storing species reference data...');
    await service.storeSpeciesReference();

    // Store birds for some common regions
    final regions = ['US-ME', 'US-MA', 'US-NY', 'US-CA'];
    for (final region in regions) {
      print('Fetching and storing birds for region $region...');
      await service.storeBirdsByRegion(region);
    }

    print('Database initialization complete!');
  } catch (e) {
    print('Error initializing database: $e');
  } finally {
    // Exit the app after completion
    print('Exiting...');
    await Future.delayed(Duration(seconds: 1));
  }
}
