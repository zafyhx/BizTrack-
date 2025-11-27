import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../inventory/add_product_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data user yang sedang login
    // final user = FirebaseAuth.instance.currentUser; // (Bisa dipakai nanti)

    return Scaffold(
      appBar: AppBar(
        title: const Text("BizTrack Dashboard"),
        actions: [
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 1. Panggil fungsi logout di Provider
              context.read<AuthProvider>().logout();
              
              // 2. Tendang balik ke halaman Login
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Pindah ke halaman Tambah Produk
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              "Selamat Datang Bos!",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const Text("Menu kasir akan muncul di sini."),
          ],
        ),
      ),
    );
  }
}