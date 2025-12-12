import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../auth/login_screen.dart';
import '../inventory/add_product_screen.dart';
import '../transaction/cashier_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE LOKAL ---
  String _selectedCategory =
      'All'; // Menyimpan kategori yang sedang dipilih user
  String _searchQuery = ''; // Menyimpan teks pencarian
  int _bottomNavIndex = 0; // Tab aktif di footer

  // DAFTAR KATEGORI LENGKAP
  final List<String> _categories = [
    'All',
    'Makanan',
    'Minuman',
    'Snack',
    'Dessert',
  ];

  @override
  Widget build(BuildContext context) {
    // Variabel Tema & Format Uang
    final primaryColor = Theme.of(context).primaryColor;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],

      // --- 1. NAVBAR ATAS (APPBAR) ---
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Menu Cafe",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: "Keluar",
          onPressed: () => _showLogoutDialog(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: "Tambah Menu Baru",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            ),
          ),
        ],
      ),

      // --- 2. BADAN KONTEN UTAMA ---
      body: Column(
        children: [
          // A. HEADER LENGKUNG & SEARCH BAR
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Temukan Favoritmu",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                // Input Pencarian
                TextField(
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Cari menu (ex: Nasi Goreng)...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),

          // B. FILTER KATEGORI (HORIZONTAL SCROLL)
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;

                return GestureDetector(
                  onTap: () {
                    // Logika Ganti Filter
                    setState(() => _selectedCategory = cat);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        else
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // C. GRID PRODUK (STREAM BUILDER)
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: context.read<ProductProvider>().getProductsStream(),
              builder: (context, snapshot) {
                // 1. Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Terjadi kesalahan: ${snapshot.error}"),
                  );
                }

                // 3. Ambil Data Mentah
                final allProducts = snapshot.data ?? [];

                // --- LOGIKA FILTER UTAMA ---
                final filteredProducts = allProducts.where((product) {
                  final matchesCategory =
                      _selectedCategory == 'All' ||
                      product.category == _selectedCategory;
                  final matchesSearch = product.name.toLowerCase().contains(
                    _searchQuery,
                  );
                  return matchesCategory && matchesSearch;
                }).toList();

                // 4. Data Kosong
                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Menu $_selectedCategory tidak ditemukan",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // 5. Tampilkan Grid
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    80,
                  ), // Padding bawah agar tidak tertutup FAB
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        0.70, // Rasio sedikit dipanjangkan agar muat tombol delete
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _buildMenuCard(
                      context,
                      product,
                      currencyFormatter,
                      primaryColor,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // --- 3. TOMBOL MELAYANG (FAB) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CashierScreen()),
          );
        },
        backgroundColor: primaryColor,
        elevation: 4,
        child: const Icon(Icons.point_of_sale, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- 4. FOOTER (BOTTOM NAVIGATION BAR) ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CashierScreen()),
            );
          } else if (index == 3) {
            _showLogoutDialog(context);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: KARTU PRODUK ---
  Widget _buildMenuCard(
    BuildContext context,
    ProductModel product,
    NumberFormat formatter,
    Color primaryColor,
  ) {
    IconData categoryIcon;
    Color iconColor;

    switch (product.category) {
      case 'Makanan':
        categoryIcon = Icons.restaurant;
        iconColor = Colors.redAccent;
        break;
      case 'Minuman':
        categoryIcon = Icons.local_drink;
        iconColor = Colors.blueAccent;
        break;
      case 'Snack':
        categoryIcon = Icons.cookie;
        iconColor = Colors.orangeAccent;
        break;
      case 'Dessert':
        categoryIcon = Icons.cake;
        iconColor = Colors.pinkAccent;
        break;
      default:
        categoryIcon = Icons.fastfood;
        iconColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Bagian untuk menampilkan ikon kategori produk
                Expanded(
                  flex: 3,
                  child: Container(
                    color: iconColor.withOpacity(0.1),
                    child: Center(
                      child: Icon(categoryIcon, size: 40, color: iconColor),
                    ),
                  ),
                ),

                // Area Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              product.category,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        // BARIS TOMBOL AKSI (HARGA - EDIT - HAPUS)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatter
                                  .format(product.price)
                                  .replaceAll("Rp ", ""),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: primaryColor,
                              ),
                            ),

                            // GABUNGAN TOMBOL EDIT DAN DELETE
                            Row(
                              children: [
                                // Tombol Edit (Biru)
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddProductScreen(
                                          productToEdit: product,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: primaryColor,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8), // Jarak antar tombol
                                // Tombol Delete (Merah) - FITUR BARU
                                InkWell(
                                  onTap: () =>
                                      _showDeleteDialog(context, product),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG LOGOUT ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- DIALOG HAPUS PRODUK (FITUR BARU) ---
  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 10),
            const Text("Hapus Menu"),
          ],
        ),
        content: Text(
          "Anda yakin ingin menghapus '${product.name}' dari database? Tindakan ini tidak bisa dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              try {
                // Panggil Provider untuk Hapus
                await context.read<ProductProvider>().deleteProduct(product.id);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Menu berhasil dihapus")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Gagal menghapus: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
