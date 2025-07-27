import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final cartRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('cart');

              final snapshot = await cartRef.get();
              for (var doc in snapshot.docs) {
                await doc.reference.delete();
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🧺 All items cleared')),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final cartItems = snapshot.data!.docs;

          if (cartItems.isEmpty) {
            return const Center(child: Text('🛒 Your cart is empty.'));
          }

          double totalPrice = 0;

          for (var doc in cartItems) {
            final data = doc.data() as Map<String, dynamic>;
            totalPrice += (data['price'] ?? 0) * (data['quantity'] ?? 1);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final product = cartItems[index];
                    final data = product.data() as Map<String, dynamic>;
                    final docRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('cart')
                        .doc(product.id);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(data['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${data['price']} EGP'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    int currentQty = data['quantity'] ?? 1;
                                    if (currentQty > 1) {
                                      docRef.update({'quantity': currentQty - 1});
                                    }
                                  },
                                ),
                                Text('${data['quantity'] ?? 1}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    int currentQty = data['quantity'] ?? 1;
                                    docRef.update({'quantity': currentQty + 1});
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => docRef.delete(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Total + Confirm Order
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Total: ${totalPrice.toStringAsFixed(2)} EGP',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showConfirmationDialog(context, uid, cartItems, totalPrice);
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Place Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String uid, List cartItems, double total) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Text('Place order for ${total.toStringAsFixed(2)} EGP?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final orderRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('orders')
                  .doc();

              final orderItems = cartItems.map((e) => e.data()).toList();

              await orderRef.set({
                'timestamp': FieldValue.serverTimestamp(),
                'items': orderItems,
                'total': total,
              });

              // clear cart
              final cartRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('cart');

              final snapshot = await cartRef.get();
              for (var doc in snapshot.docs) {
                await doc.reference.delete();
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Order placed successfully')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
