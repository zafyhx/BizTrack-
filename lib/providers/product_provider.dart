import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Wajib import ini
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  // KONEKSI KE DATABASE SPESIFIK 'biztrack-db'
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'biztrack-db', 
  );
  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- FUNGSI 1: TAMBAH PRODUK (CREATE) ---
  // Parameter bertambah: String category
  Future<void> addProduct(String name, int price, int stock, String category) async {
    try {
      _setLoading(true);
      final uid = _auth.currentUser!.uid;

      await _db.collection('users').doc(uid).collection('products').add({
        'name': name,
        'price': price,
        'stock': stock,
        'category': category, // Simpan Kategori
        'created_at': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      throw "Gagal simpan barang: $e";
    }
  }

  // --- FUNGSI 2: UPDATE PRODUK (UPDATE) ---
  // Parameter bertambah: String category
  Future<void> updateProduct(String id, String name, int price, int stock, String category) async {
    try {
      _setLoading(true);
      final uid = _auth.currentUser!.uid;

      await _db
          .collection('users')
          .doc(uid)
          .collection('products')
          .doc(id)
          .update({
            'name': name,
            'price': price,
            'stock': stock,
            'category': category, // Update Kategori
          });

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      throw "Gagal update barang: $e";
    }
  }

  // --- FUNGSI 3: HAPUS PRODUK (DELETE) ---
  Future<void> deleteProduct(String productId) async {
    try {
      final uid = _auth.currentUser!.uid;
      await _db
          .collection('users')
          .doc(uid)
          .collection('products')
          .doc(productId)
          .delete();
    } catch (e) {
      throw "Gagal menghapus barang: $e";
    }
  }

  // --- FUNGSI 4: AMBIL DATA LIVE (READ) ---
  Stream<List<ProductModel>> getProductsStream() {
    final uid = _auth.currentUser!.uid;
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}