class ProductModel {
  final String id;
  final String name;
  final int price;
  final int stock;
  final String category; // <--- FIELD BARU

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      id: documentId,
      name: data['name'] ?? 'Tanpa Nama',
      price: data['price'] ?? 0,
      stock: data['stock'] ?? 0,
      // Default ke 'Makanan' jika data lama tidak punya kategori
      category: data['category'] ?? 'Makanan',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
      'created_at': DateTime.now(),
    };
  }
}
