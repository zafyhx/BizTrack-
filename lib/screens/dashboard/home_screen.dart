import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../auth/login_screen.dart';
import '../inventory/add_product_screen.dart';
import '../transaction/cashier_screen.dart'; 
import '../../widgets/product_card.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BizTrack Dashboard"),
        actions: [
          // 1. TOMBOL TAMBAH PRODUK 
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: "Tambah Stok",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
            },
          ),
          
          // 2. TOMBOL LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Keluar",
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      
      // 3. TOMBOL BESAR KE KASIR (Baru)
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("BUKA KASIR"),
        icon: const Icon(Icons.point_of_sale),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CashierScreen()),
          );
        },
      ),

      // BADAN UTAMA (List Produk - Tidak Berubah)
      body: StreamBuilder<List<ProductModel>>(
        stream: context.read<ProductProvider>().getProductsStream(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Belum ada barang."),
                  const Text("Klik ikon kotak (+) di atas untuk tambah."),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            padding: const EdgeInsets.only(bottom: 100), // Padding bawah lebih besar biar ga ketutup tombol Kasir
            itemBuilder: (context, index) {
              final item = products[index];
              
              return ProductCard(
                product: item,
                onDelete: () => _showDeleteDialog(context, item),

                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProductScreen(productToEdit: item),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Pop-up Konfirmasi Hapus
  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Barang?"),
        content: Text("Yakin mau menghapus '${product.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<ProductProvider>().deleteProduct(product.id);
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text("Barang dihapus")),
                );
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}