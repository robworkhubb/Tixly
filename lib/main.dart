import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tixly/providers/event_provider.dart';
import 'package:tixly/providers/memory_provider.dart';
import 'package:tixly/providers/post_provider.dart';
import 'package:tixly/providers/user_provider.dart';
import 'package:tixly/providers/wallet_provider.dart';
import 'package:tixly/screens/home_page.dart';
import 'package:tixly/services/auth_service.dart';
import 'screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        Provider(create: (_) => AuthService()),
      ],
      child: const TixlyApp(),
    ),
  );
}

class TixlyApp extends StatelessWidget {
  const TixlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tixly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            Provider.of<UserProvider>(
              context,
              listen: false,
            ).loadUser(user.uid);
            return const HomePage();
          } else {
            Provider.of<UserProvider>(context, listen: false).clearUser();
            return const LoginPage();
          }
        },
      ),
    );
  }
}
