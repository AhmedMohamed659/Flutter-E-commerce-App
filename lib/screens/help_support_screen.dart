import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  void _sendSupportMessage() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      final email = user?.email;

      await FirebaseFirestore.instance.collection('support_messages').add({
        'uid': uid,
        'email': email,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Message sent successfully')));

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              '🛠️ Frequently Asked Questions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ExpansionTile(
              title: Text('How do I place an order?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Add items to your cart and click "Place Order".',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text('How do I update my profile?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Go to Settings > Edit Profile to update your information.',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '💬 Contact Us:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Your message',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a message'
                    : null,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _sendSupportMessage,
              icon: Icon(Icons.send),
              label: Text('Send Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
