import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:birdsong_trainer/services/ebird_service.dart';
import 'package:birdsong_trainer/models/bird.dart';
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
    eBirdService = EBirdService(client: mockClient);
  });

  group('EBirdService Tests', () {
    test('getBirdsByRegion returns list of birds on successful response',
        () async {
      // Mock successful response
      when(mockClient.get(
        Uri.parse('https://api.ebird.org/v2/data/obs/region/recent/US-NY'),
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

      expect(birds, isA<List<Bird>>());
      expect(birds.length, 1);
      expect(birds[0].name, 'American Crow');
      expect(birds[0].scientificName, 'Corvus brachyrhynchos');
    });

    test('getBirdsByRegion throws exception on failed response', () async {
      // Mock failed response
      when(mockClient.get(
        Uri.parse('https://api.ebird.org/v2/data/obs/region/recent/US-NY'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Error', 404));

      expect(
        () => eBirdService.getBirdsByRegion('US-NY'),
        throwsException,
      );
    });

    test('getRegions returns list of region codes on successful response',
        () async {
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

      expect(regions, isA<List<String>>());
      expect(regions.length, 2);
      expect(regions[0], 'US-NY');
      expect(regions[1], 'US-CA');
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
