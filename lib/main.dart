import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tixly/providers/comment_provider.dart';

// SERVICES & PROVIDERS
import 'services/auth_service.dart';
import 'providers/auth_provider.dart' as app;
import 'providers/user_provider.dart';
import 'providers/post_provider.dart';
import 'providers/event_provider.dart';
import 'providers/memory_provider.dart';
import 'providers/wallet_provider.dart';

// SCREENS
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/onboarding_screen.dart';

// VARIE
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
      apiKey: 'AIzaSyDd8kNx6URUmLTOqyC4ATMGevrGifBRHPY',
      authDomain: 'tixly-bb7f2.firebaseapp.com',
      projectId: 'tixly-bb7f2',
      storageBucket: 'tixly-bb7f2.appspot.com',
      messagingSenderId: '1048005640444',
      appId: '1:1048005640444:web:9af73c76d1f4afacf2d779',
      measurementId: 'G-XVFJYKZWN9',
    )
        : null,
  );
  runApp(const TixlyApp());
}

class TixlyApp extends StatefulWidget {
  const TixlyApp({super.key});

  @override
  State<TixlyApp> createState() => _TixlyAppState();
}

class _TixlyAppState extends State<TixlyApp> {
  bool _onBoardingSeen = false;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    FirebaseAuth.instance.currentUser?.reload().catchError((e) async {
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        await FirebaseAuth.instance.signOut();
      }
    });
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onBoardingSeen = prefs.getBool('onBoardingSeen') ?? false;
      _loadingPrefs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPrefs) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiProvider(
        providers: [

          /// 1️⃣  servizio puro (NON ChangeNotifier) – deve venire per primo
          Provider<AuthService>(create: (_) => AuthService()),

          /// 2️⃣  stato autenticazione – dipende dal servizio sopra
          ChangeNotifierProvider<app.AuthProvider>(
            create: (ctx) => app.AuthProvider(ctx.read<AuthService>()),
          ),

          /// 3️⃣  altri ChangeNotifier
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CommentProvider()),
          ChangeNotifierProvider(create: (_) => WalletProvider()),
          ChangeNotifierProvider(create: (_) => MemoryProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider()),
          ChangeNotifierProvider(create: (_) => PostProvider()),
        ],
        child: Consumer<app.AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.firebaseUser;
            if(user != null) {
              context.read<UserProvider>().loadUser(user.uid);
            } else {
              context.read<UserProvider>().clearUser();
            }
            debugPrint('rebuild material: $user');
            return MaterialApp(
              title: 'Tixly',
              theme: ThemeData(
                fontFamily: 'Poppins',
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              key: ValueKey(user == null ? 'login' : 'home'),

              home: _onBoardingSeen
                  ? (user == null ? const LoginPage()
                  : const HomePage())
                  : OnboardingScreen(
                onFinish: () {
                  setState(() {
                    _onBoardingSeen = true;
                  });
                },
              ),
            );
          },
        )
    );
  }
}

