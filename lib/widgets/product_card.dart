import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onDelete;
  final VoidCallback onEdit; // TAMBAHAN: Fungsi Edit

  const ProductCard({
    super.key, 
    required this.product, 
    required this.onDelete,
    required this.onEdit, // Wajib diisi
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.inventory_2_outlined, color: Theme.of(context).primaryColor),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Stok: ${product.stock} pcs", 
              style: TextStyle(color: product.stock < 5 ? Colors.red : Colors.grey)
            ),
            Text(currency.format(product.price),
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        // Bagian Kanan: Ada 2 Tombol (Edit & Hapus)
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Biar gak makan tempat
          children: [
            // TOMBOL EDIT (PENSIL)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            // TOMBOL HAPUS (SAMPAH)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}