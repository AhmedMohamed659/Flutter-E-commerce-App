import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  Future<void> addToCart(
    BuildContext context,
    Map<String, dynamic> data,
    String id,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(id)
        .set({...data, 'quantity': 1});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Added to cart')));
  }

  Future<void> addAllToCart(
    BuildContext context,
    List<QueryDocumentSnapshot> items,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final batch = FirebaseFirestore.instance.batch();

    for (var item in items) {
      final data = item.data() as Map<String, dynamic>;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(item.id);

      batch.set(docRef, {...data, 'quantity': 1});
    }

    await batch.commit();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('🛒 All items added to cart')));
  }

  Future<void> removeItem(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(id)
        .delete();
  }

  Future<void> clearWishlist() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear Wishlist',
            onPressed: () async {
              await clearWishlist();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑 Wishlist cleared')),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('wishlist')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text('❤️ Wishlist is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final data = item.data();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Image.network(
                          data['imageUrl'],
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(data['name']),
                        subtitle: Text('${data['price']} EGP'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart),
                              tooltip: 'Add to cart',
                              onPressed: () =>
                                  addToCart(context, data, item.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever),
                              tooltip: 'Remove',
                              onPressed: () => removeItem(item.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add All to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => addAllToCart(context, items),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
