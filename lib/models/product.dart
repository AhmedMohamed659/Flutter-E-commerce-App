class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.description,
  });

  factory Product.fromDocument(Map<String, dynamic> doc, String docId) {
    return Product(
      id: docId,
      name: doc['name'] ?? '',
      price: (doc['price'] ?? 0).toDouble(),
      imageUrl: doc['imageUrl'] ?? '',
      category: doc['category'] ?? '',
      description: doc['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
    };
  }
}
