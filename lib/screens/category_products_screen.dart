import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({super.key});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  String sortBy = 'none'; // none, low, high
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Products'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => searchQuery = value.trim().toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Search in $category...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text('Sort by:'),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: sortBy,
                  onChanged: (value) {
                    if (value != null) setState(() => sortBy = value);
                  },
                  items: [
                    DropdownMenuItem(value: 'none', child: Text('Default')),
                    DropdownMenuItem(
                      value: 'low',
                      child: Text('Price: Low to High'),
                    ),
                    DropdownMenuItem(
                      value: 'high',
                      child: Text('Price: High to Low'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('category', isEqualTo: category)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                List<DocumentSnapshot> products = snapshot.data!.docs.where((
                  doc,
                ) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  return name.contains(searchQuery);
                }).toList();

                if (sortBy == 'low') {
                  products.sort(
                    (a, b) => (a['price'] as num).compareTo(b['price'] as num),
                  );
                } else if (sortBy == 'high') {
                  products.sort(
                    (a, b) => (b['price'] as num).compareTo(a['price'] as num),
                  );
                }

                if (products.isEmpty) {
                  return Center(child: Text('😕 No matching products found.'));
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final data = product.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product',
                          arguments: product,
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  data['imageUrl'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('${data['price']} EGP'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
