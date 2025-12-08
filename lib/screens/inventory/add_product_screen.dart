import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  // Parameter Opsional: Null = Mode Tambah, Ada Isi = Mode Edit
  final ProductModel? productToEdit;

  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk Input Teks Biasa
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  // --- BAGIAN BARU 1: STATE UNTUK KATEGORI ---
  String _selectedCategory = 'Makanan'; // Default Value
  final List<String> _categories = ['Makanan', 'Minuman', 'Snack', 'Dessert'];

  @override
  void initState() {
    super.initState();

    // LOGIKA PINTAR: Cek apakah ini mode Edit?
    if (widget.productToEdit != null) {
      // 1. Isi data teks (Nama, Harga, Stok)
      _nameController.text = widget.productToEdit!.name;
      _priceController.text = widget.productToEdit!.price.toString();
      _stockController.text = widget.productToEdit!.stock.toString();

      // 2. Isi data Kategori (Validasi agar tidak error jika kategori lama tidak ada di list)
      if (_categories.contains(widget.productToEdit!.category)) {
        _selectedCategory = widget.productToEdit!.category;
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final provider = context.read<ProductProvider>();
      final name = _nameController.text.trim();
      final price = int.parse(_priceController.text);
      final stock = int.parse(_stockController.text);

      // --- BAGIAN BARU 2: KIRIM PARAMETER KATEGORI KE PROVIDER ---
      if (widget.productToEdit == null) {
        // Mode Tambah
        await provider.addProduct(name, price, stock, _selectedCategory);
      } else {
        // Mode Edit
        await provider.updateProduct(
          widget.productToEdit!.id,
          name,
          price,
          stock,
          _selectedCategory, // Jangan lupa kirim kategori yang diedit
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoading;
    final isEditMode = widget.productToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Menu" : "Tambah Menu Baru"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INPUT NAMA
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Menu",
                  prefixIcon: Icon(Icons.fastfood),
                ),
                validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 20),

              // --- BAGIAN BARU 3: DROPDOWN PILIHAN KATEGORI ---
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // INPUT HARGA & STOK
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: "Harga",
                        prefixText: "Rp ",
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib isi" : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: "Stok",
                        suffixText: "Porsi",
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib isi" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50, // Tombol besar agar mudah ditekan
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text(isEditMode ? "UPDATE MENU" : "SIMPAN MENU"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
