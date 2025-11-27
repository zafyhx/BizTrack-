import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart'; // Import Model

class AddProductScreen extends StatefulWidget {
  // Tambahkan parameter Opsional
  // Kalau null = Mode Tambah. Kalau ada isinya = Mode Edit.
  final ProductModel? productToEdit;

  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // LOGIKA PINTAR: Cek apakah ini mode Edit?
    if (widget.productToEdit != null) {
      // Jika iya, isi formulir dengan data lama
      _nameController.text = widget.productToEdit!.name;
      _priceController.text = widget.productToEdit!.price.toString();
      _stockController.text = widget.productToEdit!.stock.toString();
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final provider = context.read<ProductProvider>();
      final name = _nameController.text.trim();
      final price = int.parse(_priceController.text);
      final stock = int.parse(_stockController.text);

      if (widget.productToEdit == null) {
        // --- MODE TAMBAH BARU ---
        await provider.addProduct(name, price, stock);
      } else {
        // --- MODE UPDATE (EDIT) ---
        await provider.updateProduct(
          widget.productToEdit!.id, // ID Lama jangan berubah
          name, 
          price, 
          stock
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil disimpan!")),
      );
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
    // Ubah Judul Halaman sesuai Mode
    final isEditMode = widget.productToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Barang" : "Tambah Barang Baru"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Produk",
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: "Harga Jual",
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
                        suffixText: "Pcs",
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib isi" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      // Ubah tulisan tombol sesuai Mode
                      child: Text(isEditMode ? "UPDATE DATA" : "SIMPAN BARU"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}