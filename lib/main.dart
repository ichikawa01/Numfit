import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';
import 'screens/difficulty_select_screen.dart';
import 'screens/stage_select_screen.dart';
import 'utils/audio_manager.dart';
import 'screens/settings_screen.dart';


void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await AudioManager.init();
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '数学ピラミッド',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
      '/': (context) => const HomeScreen(),
      '/difficulty-select': (context) => const DifficultySelectScreen(),
      '/stage-select': (context) => const StageSelectScreen(),
      '/game': (context) => const GameScreen(),
      '/result': (context) => const ResultScreen(),
      '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
