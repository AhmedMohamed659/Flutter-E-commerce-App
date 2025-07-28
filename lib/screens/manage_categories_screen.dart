import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _newCategoryController = TextEditingController();
  bool isLoading = false;

  Future<void> _addCategory() async {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) return;

    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('categories').add({
        'name': name,
        'hidden': false,
      });
      _newCategoryController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _confirmDeleteCategory(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(id)
          .delete();
    }
  }

  Future<void> _toggleHidden(String id, bool currentHidden) async {
    await FirebaseFirestore.instance.collection('categories').doc(id).update({
      'hidden': !currentHidden,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Categories')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _newCategoryController,
              decoration: InputDecoration(
                labelText: 'New Category Name',
                suffixIcon: isLoading
                    ? CircularProgressIndicator()
                    : IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _addCategory,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Current Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  final categories = snapshot.data!.docs;

                  if (categories.isEmpty) return Text('No categories found.');

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final doc = categories[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name'] ?? 'Unnamed';
                      final hidden = data['hidden'] ?? false;

                      return ListTile(
                        title: Text(name),
                        subtitle: Text(hidden ? 'Hidden' : 'Visible'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                hidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: hidden ? Colors.grey : Colors.green,
                              ),
                              onPressed: () => _toggleHidden(doc.id, hidden),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteCategory(doc.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
