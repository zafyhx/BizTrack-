class ProductModel {
  final String id;
  final String name;
  final int price;
  final int stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  // Fungsi 1: Mengubah Data dari Firebase (Map) menjadi Object Dart
  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      id: documentId,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      stock: data['stock'] ?? 0,
    );
  }

  // Fungsi 2: Mengubah Object Dart menjadi Map untuk disimpan ke Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'created_at': DateTime.now(),
    };
  }
}