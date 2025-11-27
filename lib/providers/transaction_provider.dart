import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/product_model.dart';

class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'biztrack-db', 
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // KERANJANG BELANJA (List Sementara)
  final List<CartItem> _cart = [];
  List<CartItem> get cart => _cart;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Hitung Total Belanjaan
  int get grandTotal {
    int total = 0;
    for (var item in _cart) {
      total += item.subtotal;
    }
    return total;
  }

  // --- FUNGSI 1: TAMBAH KE KERANJANG ---
  void addToCart(ProductModel product, int qty) {
    // Cek apakah barang sudah ada di keranjang?
    final index = _cart.indexWhere((item) => item.productId == product.id);

    if (index != -1) {
      // Jika ada, tambahkan qty-nya saja
      _cart[index].qty += qty;
    } else {
      // Jika belum ada, masukkan barang baru
      _cart.add(CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        qty: qty,
      ));
    }
    notifyListeners(); // Update UI
  }

  // --- FUNGSI 2: HAPUS DARI KERANJANG ---
  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  // --- FUNGSI 3: CHECKOUT (BOSS LEVEL) ---
  Future<void> checkout() async {
    if (_cart.isEmpty) throw "Keranjang kosong!";
    
    try {
      _setLoading(true);
      final uid = _auth.currentUser!.uid;
      final batch = _db.batch(); // Batch Write: Semuanya sukses atau semuanya gagal

      // A. Siapkan Data Transaksi
      final transactionRef = _db
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(); // Generate ID otomatis

      batch.set(transactionRef, {
        'totalPrice': grandTotal,
        'date': FieldValue.serverTimestamp(),
        'items': _cart.map((e) => e.toMap()).toList(), // Simpan detail barang
      });

      // B. Kurangi Stok Produk (Satu per satu)
      for (var item in _cart) {
        final productRef = _db
            .collection('users')
            .doc(uid)
            .collection('products')
            .doc(item.productId);
        
        // Logika Firestore: stock = stock - qty
        batch.update(productRef, {
          'stock': FieldValue.increment(-item.qty),
        });
      }

      // C. Eksekusi Batch (Kirim ke Internet)
      await batch.commit();

      // D. Bersihkan Keranjang
      _cart.clear();
      _setLoading(false);

    } catch (e) {
      _setLoading(false);
      throw "Gagal Transaksi: $e";
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}