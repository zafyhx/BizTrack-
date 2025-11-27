import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  // --- PERUBAHAN PENTING DI SINI ---
  // Kita hubungkan spesifik ke database ID 'biztrack-db'
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'biztrack-db', 
  );
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- FUNGSI TAMBAH PRODUK ---
  Future<void> addProduct(String name, int price, int stock) async {
    try {
      _setLoading(true);
      
      // Cek apakah user sudah login
      final user = _auth.currentUser;
      if (user == null) {
        throw "User tidak terdeteksi (Belum Login)";
      }

      // 1. Ambil ID User
      final uid = user.uid;

      // 2. Simpan ke path: users -> [UID] -> products
      await _db.collection('users').doc(uid).collection('products').add({
        'name': name,
        'price': price,
        'stock': stock,
        'created_at': FieldValue.serverTimestamp(),
      });

      print("✅ SUKSES: Data $name tersimpan di biztrack-db");
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      print("❌ ERROR DETAIL: $e"); // Supaya kelihatan di debug console
      throw "Gagal menyimpan barang: $e";
    }
  }

  // --- FUNGSI AMBIL DATA (STREAM) ---
  Stream<List<ProductModel>> getProductsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      // Return stream kosong jika belum login daripada error
      return Stream.value([]); 
    }

    final uid = user.uid;

    return _db
        .collection('users')
        .doc(uid)
        .collection('products')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ProductModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // --- FUNGSI HAPUS PRODUK ---
  Future<void> deleteProduct(String productId) async {
    try {
      final uid = _auth.currentUser?.uid;

      await _db
          .collection('users')
          .doc(uid)
          .collection('products')
          .doc(productId)
          .delete();
    } catch (e) {
      print("❌ ERROR DETAIL: $e");
      throw "Gagal menghapus barang: $e";
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}