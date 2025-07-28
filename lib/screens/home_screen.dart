import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildCategoryChip(BuildContext context, String name) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/category_products', arguments: name);
      },
      child: Chip(label: Text(name), backgroundColor: Colors.teal.shade100),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final primaryColor = Colors.teal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('My Store'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      drawer: buildAppDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get(),
              builder: (context, snapshot) {
                final user = snapshot.data?.data() as Map<String, dynamic>?;
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Hello, ${user?['name'] ?? 'User'} 👋',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip(context, 'Electronics'),
                  SizedBox(width: 8),
                  _buildCategoryChip(context, 'Fashion'),
                  SizedBox(width: 8),
                  _buildCategoryChip(context, 'Shoes'),
                ],
              ),
            ),

            SizedBox(height: 20),

            CarouselSlider(
              items:
                  [
                    'https://m.media-amazon.com/images/I/91YSwvno72L._UF894,1000_QL80_.jpg',
                    'https://static.nike.com/a/images/t_PDP_936_v1/f_auto,q_auto:eco/a7f07bf7-7896-48c7-b53d-ab5daf86f84e/NIKE+AIR+MAX+EXCEE.png',
                    'https://m.media-amazon.com/images/I/91OE4wbLSOL._AC._SR360,460.jpg',
                  ].map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: Center(child: Icon(Icons.image_not_supported)),
                        ),
                      ),
                    );
                  }).toList(),
              options: CarouselOptions(
                height: 160,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final data = product.data();

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/product',
                            arguments: product,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                data['imageUrl'],
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                data['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('${data['price']} EGP'),
                            ),
                            Spacer(),
                            StatefulBuilder(
                              builder: (context, setState) {
                                bool isFav = false;

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isFav
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFav ? Colors.red : null,
                                      ),
                                      onPressed: () async {
                                        final uid = FirebaseAuth
                                            .instance
                                            .currentUser!
                                            .uid;
                                        final favRef = FirebaseFirestore
                                            .instance
                                            .collection('users')
                                            .doc(uid)
                                            .collection('wishlist')
                                            .doc(product.id);

                                        if (isFav) {
                                          await favRef.delete();
                                          setState(() => isFav = false);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '❌ Removed from wishlist',
                                              ),
                                            ),
                                          );
                                        } else {
                                          await favRef.set(data);
                                          setState(() => isFav = true);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '❤️ Added to wishlist',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_shopping_cart),
                                      onPressed: () async {
                                        final uid = FirebaseAuth
                                            .instance
                                            .currentUser!
                                            .uid;
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .collection('cart')
                                            .doc(product.id)
                                            .set({...data, 'quantity': 1});

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('🛒 Added to cart'),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
