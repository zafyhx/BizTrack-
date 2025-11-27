import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';

import 'core/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cek Aplikasi Berjalan
  if (Firebase.apps.isEmpty) {
    // Tidak ada = Inisialisasi 
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // Sudah ada = Gunakan yang sudah ada
    Firebase.app(); 
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BizTrack PBB',
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
