import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/bird_list_selection_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/training_setup_screen.dart';
import 'screens/training_screen.dart';
import 'screens/bird_list_edit_screen.dart';
import 'providers/settings_provider.dart';
import 'providers/bird_list_provider.dart';
import 'models/bird_list.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['EBIRD_API_KEY'];
    if (apiKey == null) {
      throw Exception('EBIRD_API_KEY not found in .env file');
    }

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    runApp(
      const ProviderScope(
        child: BirdsongTrainerApp(),
      ),
    );
  } catch (e) {
    print('Error during initialization: $e');
    rethrow;
  }
}

class BirdsongTrainerApp extends ConsumerWidget {
  const BirdsongTrainerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Birdsong Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/lists': (context) => const BirdListSelectionScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/training-setup': (context) {
          final list = ModalRoute.of(context)!.settings.arguments as BirdList;
          return TrainingSetupScreen(birdList: list);
        },
        '/training': (context) => const TrainingScreen(),
        '/edit-list': (context) {
          final list = ModalRoute.of(context)!.settings.arguments as BirdList;
          return BirdListEditScreen(list: list);
        },
      },
    );
  }
}
