import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  // Instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _setLoading(true);

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      throw _handleError(e.code);
    } catch (e) {
      _setLoading(false);
      throw "Terjadi Kesalahan Pada Sistem: $e";
    }
  }

  // Register
  Future<bool> register(String email, String password) async {
    try {
      _setLoading(true);

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      throw _handleError(e.code);
    } catch (e) {
      _setLoading(false);
      throw "Gagal mendaftar: $e";
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Helper : Mengubah status loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Helper : Menerjemahkan Firebase
  String _handleError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak ditemukan. Silakan daftar dulu.';
      case 'wrong-password':
        return 'Password salah. Coba ingat-ingat lagi.';
      case 'email-already-in-use':
        return 'Email ini sudah dipakai akun lain.';
      case 'invalid-email':
        return 'Format email tidak valid (kurang @ atau .com).';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      default:
        return 'Gagal login. Kode Error: $code';
    }
  }
}
