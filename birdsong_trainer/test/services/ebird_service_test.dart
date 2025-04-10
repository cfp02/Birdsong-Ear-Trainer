import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:birdsong_trainer/services/ebird_service.dart';
import 'dart:io';

class MockClient extends Mock implements http.Client {}

void main() {
  late EBirdService eBirdService;
  late MockClient mockClient;

  setUpAll(() async {
    // Load test environment variables
    final testEnvPath = File('test/.env.test').absolute.path;
    await dotenv.load(fileName: testEnvPath);
  });

  setUp(() {
    mockClient = MockClient();
    eBirdService = EBirdService();
  });

  group('EBirdService Tests', () {
    test('getBirdsByRegion returns list of birds on successful response',
        () async {
      // Mock successful response
      when(mockClient.get(
        Uri.parse('https://api.ebird.org/v2/data/obs/US-NY/recent'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            '''
        [
          {
            "speciesCode": "amecro",
            "comName": "American Crow",
            "sciName": "Corvus brachyrhynchos",
            "locName": "New York"
          }
        ]
        ''',
            200,
          ));

      final birds = await eBirdService.getBirdsByRegion('US-NY');

      expect(birds, isA<List<Map<String, dynamic>>>());
      expect(birds.length, 1);
      expect(birds[0]['comName'], 'American Crow');
      expect(birds[0]['sciName'], 'Corvus brachyrhynchos');
    });

    test('getBirdsByRegion throws exception on failed response', () async {
      // Mock failed response
      when(mockClient.get(
        Uri.parse('https://api.ebird.org/v2/data/obs/US-NY/recent'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Error', 404));

      expect(
        () => eBirdService.getBirdsByRegion('US-NY'),
        throwsException,
      );
    });

    test('getRegions returns list of regions on successful response', () async {
      // Mock successful response
      when(mockClient.get(
        Uri.parse('https://api.ebird.org/v2/ref/region/list/subnational1/US'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            '''
        [
          {"code": "US-NY", "name": "New York"},
          {"code": "US-CA", "name": "California"}
        ]
        ''',
            200,
          ));

      final regions = await eBirdService.getRegions();

      expect(regions, isA<List<Map<String, dynamic>>>());
      expect(regions.length, 2);
      expect(regions[0]['code'], 'US-NY');
      expect(regions[0]['name'], 'New York');
      expect(regions[1]['code'], 'US-CA');
      expect(regions[1]['name'], 'California');
    });

    test('getRegions throws exception on failed response', () async {
      // Mock failed response
      when(mockClient.get(
        Uri.parse('https://api.ebird.org/v2/ref/region/list/subnational1/US'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Error', 404));

      expect(
        () => eBirdService.getRegions(),
        throwsException,
      );
    });

    test('getBirdsByFamily throws UnimplementedError', () async {
      expect(
        () => eBirdService.getBirdsByFamily('Thrush'),
        throwsUnimplementedError,
      );
    });
  });
}
