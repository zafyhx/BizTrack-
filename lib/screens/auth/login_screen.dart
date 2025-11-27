import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Pengontrol Input Teks
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Kunci Validasi Form (Agar tidak bisa submit kosong)
  final _formKey = GlobalKey<FormState>();

  // Fungsi saat tombol ditekan
  void _submit() async {
    // 1. Cek apakah email/pass kosong?
    if (!_formKey.currentState!.validate()) return;

    // 2. Panggil Provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 3. Coba Login
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 4. Jika sukses, pindah ke Dashboard
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

    } catch (e) {
      // 5. Jika gagal, munculkan pesan error merah di bawah
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil status loading dari Provider
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO / ICON
                Icon(
                  Icons.verified_user_outlined, 
                  size: 80, 
                  color: Theme.of(context).primaryColor
                ),
                const SizedBox(height: 20),
                
                Text(
                  "BizTrack Masuk",
                  style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 40),

                // INPUT EMAIL
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  // Validasi: Tidak boleh kosong & harus ada @
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email wajib diisi";
                    if (!value.contains("@")) return "Format email salah";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // INPUT PASSWORD
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Sembunyikan text
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Password minimal 6 karakter";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // TOMBOL LOGIN (Berubah jadi Loading kalau dipencet)
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text("MASUK SEKARANG"),
                      ),
                
                const SizedBox(height: 20),
                
                // TOMBOL DAFTAR 
                TextButton(
                  onPressed: () async {
                    // Quick Register Logic (Daftar cepat untuk testing)
                     if (!_formKey.currentState!.validate()) return;
                     try {
                       await context.read<AuthProvider>().register(
                         _emailController.text.trim(),
                         _passwordController.text.trim()
                       );
                       if (!mounted) return;
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Akun dibuat! Silakan Login."))
                       );
                     } catch (e) {
                       if (!mounted) return;
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text(e.toString()))
                       );
                     }
                  },
                  child: const Text("Belum punya akun? Daftar disini (Klik)"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}