import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ebird_provider.dart';
import '../providers/training_preferences_provider.dart';
import '../models/region.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = ref.watch(regionsProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);
    final preferences = ref.watch(trainingPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Training Region',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select your region to see relevant bird species',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          regions.when(
            data: (regionList) => DropdownButtonFormField<String>(
              value: selectedRegion,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Region',
              ),
              items: regionList.map((region) {
                return DropdownMenuItem<String>(
                  value: region.code,
                  child: Text(region.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(selectedRegionProvider.notifier).state = value;
                }
              },
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading regions: $error'),
          ),
          const SizedBox(height: 32),
          const Text(
            'Training Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Use 10-second clips'),
            subtitle: const Text('Play shorter clips instead of full songs'),
            value: preferences.useShortClips,
            onChanged: (value) {
              ref
                  .read(trainingPreferencesProvider.notifier)
                  .setUseShortClips(value);
            },
          ),
          SwitchListTile(
            title: const Text('Randomize clip start'),
            subtitle: const Text('Start clips at random points in the song'),
            value: preferences.randomizeClipStart,
            onChanged: (value) {
              ref
                  .read(trainingPreferencesProvider.notifier)
                  .setRandomizeClipStart(value);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Playback Mode',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          RadioListTile<PlaybackMode>(
            title: const Text('Single Call'),
            subtitle: const Text('One song plays, you guess'),
            value: PlaybackMode.single,
            groupValue: preferences.playbackMode,
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(trainingPreferencesProvider.notifier)
                    .setPlaybackMode(value);
              }
            },
          ),
          RadioListTile<PlaybackMode>(
            title: const Text('Pair Mode'),
            subtitle: const Text('Two back-to-back songs'),
            value: PlaybackMode.pair,
            groupValue: preferences.playbackMode,
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(trainingPreferencesProvider.notifier)
                    .setPlaybackMode(value);
              }
            },
          ),
          RadioListTile<PlaybackMode>(
            title: const Text('Triplet Mode'),
            subtitle: const Text('Three songs for harder training'),
            value: PlaybackMode.triplet,
            groupValue: preferences.playbackMode,
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(trainingPreferencesProvider.notifier)
                    .setPlaybackMode(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
