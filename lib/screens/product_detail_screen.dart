import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product =
        ModalRoute.of(context)!.settings.arguments as DocumentSnapshot;
    final data = product.data() as Map<String, dynamic>;

    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text(data['name']), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              data['imageUrl'],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${data['price']} EGP',
                    style: TextStyle(fontSize: 20, color: Colors.teal),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Product Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    data['description'] ?? 'No description available.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 36),

                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  ExpansionTile(
                    title: Text('Is this product original?'),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Yes, all our products are 100% original and authentic.',
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text('Does it come with a warranty?'),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Most products include a manufacturer warranty. Please check the description for more details.',
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text('What is the return policy?'),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'You can return the product within 14 days if it is unused and in original packaging.',
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text('How long does delivery take?'),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Delivery usually takes 2/5 business days depending on your location.',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.shopping_cart),
                          label: Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('cart')
                                .doc(product.id)
                                .set({...data, 'quantity': 1});

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('✅ Added to cart')),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12),

                      IconButton(
                        icon: Icon(Icons.favorite_border),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('wishlist')
                              .doc(product.id)
                              .set(data);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('❤️ Added to wishlist')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
