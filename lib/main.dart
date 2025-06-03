import 'package:flutter/material.dart';
import 'package:numfit/screens/daily_game_screen.dart';
import 'package:numfit/screens/how_to_play_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stage_select_screen.dart';
import 'utils/audio_manager.dart';
import 'screens/settings_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/daily_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await AudioManager.init();
  MobileAds.instance.initialize();
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

      supportedLocales: const [
        Locale('en'), // 英語
        Locale('ja'), // 日本語
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale?.languageCode) {
            return supported;
          }
        }
        return supportedLocales.first;
      },

      initialRoute: '/',
      routes: {
      '/': (context) => const HomeScreen(),
      '/stage-select': (context) => const StageSelectScreen(),
      '/game': (context) => const GameScreen(),
      '/result': (context) => const ResultScreen(),
      '/settings': (context) => const SettingsScreen(),
      '/collection': (context) => const CollectionScreen(),
      '/daily': (context) => const DailyScreen(),
      '/daily-play': (context) => const DailyGameScreen(),
      '/how-to-play': (context) => const HowToPlayScreen(),
      },
    );
  }
}
