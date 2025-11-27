import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/product_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/product_model.dart';

class CashierScreen extends StatelessWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kasir")),
      
      // BAGIAN BAWAH: TOTAL & TOMBOL BAYAR
      bottomNavigationBar: const _BottomCheckoutSection(),

      // BAGIAN UTAMA: DAFTAR PRODUK
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          return StreamBuilder<List<ProductModel>>(
            stream: provider.getProductsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text("Error"));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final products = snapshot.data!;

              if (products.isEmpty) {
                return const Center(child: Text("Stok Kosong. Tambah barang dulu."));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductItem(product: product);
                },
              );
            },
          );
        },
      ),
    );
  }
}

// WIDGET KECIL: Tampilan Item Produk untuk Kasir
class _ProductItem extends StatelessWidget {
  final ProductModel product;
  const _ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    // Cek Stok Habis
    bool isOutOfStock = product.stock <= 0;

    return Card(
      color: isOutOfStock ? Colors.grey[200] : null,
      child: ListTile(
        leading: Icon(Icons.shopping_bag, color: isOutOfStock ? Colors.grey : Colors.blue),
        title: Text(product.name, style: TextStyle(decoration: isOutOfStock ? TextDecoration.lineThrough : null)),
        subtitle: Text("${currency.format(product.price)} | Stok: ${product.stock}"),
        trailing: isOutOfStock 
          ? const Text("HABIS", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 36),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Beli"),
              onPressed: () {
                // Tambah ke keranjang via Provider
                context.read<TransactionProvider>().addToCart(product, 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${product.name} masuk keranjang"),
                    duration: const Duration(milliseconds: 500),
                  )
                );
              },
            ),
      ),
    );
  }
}

// WIDGET BAWAH: Panel Checkout
class _BottomCheckoutSection extends StatelessWidget {
  const _BottomCheckoutSection();

  @override
  Widget build(BuildContext context) {
    // Ambil data dari TransactionProvider
    final transProvider = context.watch<TransactionProvider>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Biar gakuh satu layar
        children: [
          // Tampilkan Item di Keranjang (Mini List)
          if (transProvider.cart.isNotEmpty)
            Container(
              height: 100, // Batasi tinggi
              margin: const EdgeInsets.only(bottom: 10),
              child: ListView.builder(
                itemCount: transProvider.cart.length,
                itemBuilder: (ctx, i) {
                  final item = transProvider.cart[i];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${item.qty}x ${item.productName}"),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                        onPressed: () => transProvider.removeFromCart(item.productId),
                      )
                    ],
                  );
                },
              ),
            ),

          // Total & Tombol Bayar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Bayar", style: TextStyle(color: Colors.grey)),
                  Text(
                    currency.format(transProvider.grandTotal),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: transProvider.cart.isEmpty || transProvider.isLoading
                    ? null // Matikan tombol jika kosong/loading
                    : () async {
                        try {
                          await transProvider.checkout();
                          if (!context.mounted) return;
                          
                          // Tampilkan Dialog Sukses
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Transaksi Sukses!"),
                              content: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                )
                              ],
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                          );
                        }
                      },
                child: transProvider.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text("BAYAR SEKARANG", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}