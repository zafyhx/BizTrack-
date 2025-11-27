import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller Text
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Panggil Provider untuk simpan
      await context.read<ProductProvider>().addProduct(
        _nameController.text.trim(),
        int.parse(_priceController.text), // Ubah teks jadi angka
        int.parse(_stockController.text),
      );

      if (!mounted) return;
      
      // Tampilkan pesan sukses & Tutup halaman
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Barang berhasil disimpan!")),
      );
      Navigator.pop(context); // Kembali ke Dashboard

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Barang Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // INPUT NAMA
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Produk",
                  hintText: "Contoh: Kopi Susu",
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  // INPUT HARGA
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      // Hanya boleh angka
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: "Harga Jual",
                        prefixText: "Rp ",
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib isi" : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // INPUT STOK
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: "Stok Awal",
                        suffixText: "Pcs",
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib isi" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // TOMBOL SIMPAN
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveProduct,
                      child: const Text("SIMPAN KE DATABASE"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}