import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ordersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final snapshot = await ordersRef.get();
              for (var doc in snapshot.docs) {
                await doc.reference.delete();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🧺 All orders cleared')),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text('📦 No orders found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final total = data['total'] ?? 0;

              final items = data['items'] as List<dynamic>? ?? [];

              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final formattedDate = timestamp != null
                  ? '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}'
                  : 'Unknown Date';

              final orderId = '#${order.id.substring(0, 6).toUpperCase()}';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text('Order $orderId'),
                  subtitle: Text('🗓 $formattedDate\n✅ Status: Completed\n 💵 Total: ${total.toStringAsFixed(2)} EGP'),
                  children: items.map((item) {
                    final name = item['name'] ?? 'Item';
                    final price = item['price'] ?? 0;
                    final quantity = item['quantity'] ?? 1;
                    final imageUrl = item['imageUrl'] ?? '';

                    return ListTile(
                      leading: imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.shopping_bag),
                      title: Text(name),
                      subtitle: Text('$price EGP x $quantity'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
