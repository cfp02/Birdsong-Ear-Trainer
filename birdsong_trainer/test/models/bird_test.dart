import 'package:flutter_test/flutter_test.dart';
import 'package:birdsong_trainer/models/bird.dart';

void main() {
  group('Bird Model Tests', () {
    test('Bird fromJson creates correct model', () {
      final json = {
        'id': '1',
        'name': 'American Robin',
        'scientificName': 'Turdus migratorius',
        'family': 'Turdidae',
        'region': 'North America',
        'audioUrl': 'https://example.com/robin.mp3',
        'difficulty': 2,
        'imageUrl': 'https://example.com/robin.jpg',
      };

      final bird = Bird.fromJson(json);

      expect(bird.id, '1');
      expect(bird.name, 'American Robin');
      expect(bird.scientificName, 'Turdus migratorius');
      expect(bird.family, 'Turdidae');
      expect(bird.region, 'North America');
      expect(bird.audioUrl, 'https://example.com/robin.mp3');
      expect(bird.difficulty, 2);
      expect(bird.imageUrl, 'https://example.com/robin.jpg');
    });

    test('Bird toJson creates correct JSON', () {
      final bird = Bird(
        id: '1',
        name: 'American Robin',
        scientificName: 'Turdus migratorius',
        family: 'Turdidae',
        region: 'North America',
        audioUrl: 'https://example.com/robin.mp3',
        difficulty: 2,
        imageUrl: 'https://example.com/robin.jpg',
      );

      final json = bird.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'American Robin');
      expect(json['scientificName'], 'Turdus migratorius');
      expect(json['family'], 'Turdidae');
      expect(json['region'], 'North America');
      expect(json['audioUrl'], 'https://example.com/robin.mp3');
      expect(json['difficulty'], 2);
      expect(json['imageUrl'], 'https://example.com/robin.jpg');
    });
  });
}
