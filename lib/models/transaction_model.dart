class CartItem {
  final String productId;
  final String productName;
  final int price;
  int qty; // Bisa diubah (mutable)

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
  });

  // Hitung subtotal per item (Harga x Jumlah)
  int get subtotal => price * qty;
  
  // Ubah ke Map untuk disimpan di database
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'qty': qty,
    };
  }
}

class TransactionModel {
  final String id;
  final int totalPrice;
  final DateTime date;
  final List<CartItem> items;

  TransactionModel({
    required this.id,
    required this.totalPrice,
    required this.date,
    required this.items,
  });
}