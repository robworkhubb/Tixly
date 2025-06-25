import 'package:flutter/material.dart';
//PROVIDERS
import 'package:tixly/providers/event_provider.dart';
import 'package:tixly/providers/memory_provider.dart';
import 'package:tixly/providers/post_provider.dart';
import 'package:tixly/providers/user_provider.dart';
import 'package:tixly/providers/wallet_provider.dart';
//SCREENS
import 'screens/login_page.dart';
import 'package:tixly/screens/home_page.dart';
import 'package:tixly/screens/onboarding_screen.dart';
//SERVICES
import 'package:tixly/services/auth_service.dart';
//FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
//VARIE
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDd8kNx6URUmLTOqyC4ATMGevrGifBRHPY",
        authDomain: "tixly-bb7f2.firebaseapp.com",
        projectId: "tixly-bb7f2",
        storageBucket: "tixly-bb7f2.firebasestorage.app",
        messagingSenderId: "1048005640444",
        appId: "1:1048005640444:web:9af73c76d1f4afacf2d779",
        measurementId: "G-XVFJYKZWN9",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(TixlyApp());
}

class TixlyApp extends StatefulWidget {
  const TixlyApp({super.key});

  @override
  State<TixlyApp> createState() => _TixlyAppState();
}

class _TixlyAppState extends State<TixlyApp> {
  bool _userLoaded = false;
  bool _onBoardingSeen = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    FirebaseAuth.instance.currentUser?.reload().catchError((e) async {
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        await FirebaseAuth.instance.signOut();
      }
    });
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final onBoardingSeen = prefs.getBool('onBoardingSeen') ?? false;
    setState(() {
      _onBoardingSeen = onBoardingSeen;
      _loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if(_loading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        Provider(create: (_) => AuthService()),
      ],
    child: MaterialApp(
      title: 'Tixly',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _onBoardingSeen
        ? StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print('Snapshot: ${snapshot.connectionState}');
          print('Utente: ${snapshot.data}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            if (!_userLoaded) {
              _userLoaded = true;
              Provider.of<UserProvider>(context, listen: false).loadUser(user.uid);
            }
            return const HomePage();
          } else {
            Provider.of<UserProvider>(context, listen: false).clearUser();
            _userLoaded = false;
            return const LoginPage();
          }
        },
      ) : const OnboardingScreen(),
    ),
    );
  }
}
