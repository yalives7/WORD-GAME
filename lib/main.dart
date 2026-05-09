import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/player_provider.dart';
import 'screens/home_screen.dart';
import 'screens/username_screen.dart';
import 'services/dictionary_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.migrateIfNeeded();
  await DictionaryService.load();
  runApp(const KelimeAvcisiApp());
}

class KelimeAvcisiApp extends StatelessWidget {
  const KelimeAvcisiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'Kelime Avcısı',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const _SplashRouter(),
      ),
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final playerProvider = context.read<PlayerProvider>();
    final existingUser = await playerProvider.loadCurrentUser();

    if (!mounted) return;

    if (existingUser != null) {
      // Kayıtlı kullanıcı var → doğrudan ana ekrana
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // İlk açılış → kullanıcı adı ekranına
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UsernameScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0F1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎮', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text(
              'KELİME AVCISI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Color(0xFF4A90D9)),
          ],
        ),
      ),
    );
  }
}
