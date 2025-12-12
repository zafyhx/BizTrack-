/// Model untuk data produk dalam sistem inventori
class ProductModel {
  /// Identitas unik produk dari Firestore document ID
  final String id;

  /// Nama produk
  final String name;

  /// Harga produk dalam rupiah
  final int price;

  /// Jumlah stok produk yang tersedia
  final int stock;

  /// Kategori produk (Makanan, Minuman, dll)
  final String category;

  /// Constructor untuk membuat instance ProductModel dengan parameter required
  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
  });

  /// Factory constructor untuk mengkonversi data dari Firestore ke ProductModel
  /// [data] adalah Map yang diambil dari Firestore
  /// [documentId] adalah ID dokumen dari Firestore
  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      id: documentId,
      name: data['name'] ?? 'Tanpa Nama',
      price: data['price'] ?? 0,
      stock: data['stock'] ?? 0,
      category: data['category'] ?? 'Makanan',
    );
  }

  /// Mengkonversi ProductModel ke Map untuk disimpan ke Firestore
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
