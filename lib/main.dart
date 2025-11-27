import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';

import 'core/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // pakai try-catch untuk menangani error duplicate Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Kalau errornya bilang "duplicate", kita abaikan karena artinya Firebase sudah nyala.
    // Kalau error lain, baru kita print supaya tahu masalahnya.
    if (e.toString().contains('duplicate')) {
      debugPrint("⚠️ Info: Firebase sudah aktif sebelumnya. Lanjut gaskan.");
    } else {
      debugPrint("❌ Error Fatal Firebase: $e");
    }
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
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
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