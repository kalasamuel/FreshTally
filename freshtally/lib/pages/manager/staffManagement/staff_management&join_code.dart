import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageStaffPage extends StatelessWidget {
  final String supermarketId;

  const ManageStaffPage({super.key, required this.supermarketId});

  @override
  Widget build(BuildContext context) {
    final joinCodeRef = FirebaseFirestore.instance
        .collection('supermarkets')
        .doc(supermarketId)
        .collection('meta')
        .doc('join_code');

    final staffRef = FirebaseFirestore.instance
        .collection('supermarkets')
        .doc(supermarketId)
        .collection('staff');

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Staff')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Staff Join Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<DocumentSnapshot>(
              future: joinCodeRef.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text('No join code found.');
                }

                final code = snapshot.data!['code'] ?? 'N/A';
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Join Code: $code',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Staff Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: staffRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No staff members.'));
                  }

                  final staffDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: staffDocs.length,
                    itemBuilder: (context, index) {
                      final staff = staffDocs[index];
                      final data = staff.data() as Map<String, dynamic>;
                      final name = data['name'] ?? 'Unnamed';
                      final role = data['role'] ?? 'Unknown';

                      return Card(
                        child: ListTile(
                          title: Text(name),
                          subtitle: Text(role),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _showEditStaffDialog(
                                    context,
                                    staff.id,
                                    name,
                                    role,
                                    staffRef,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: Text(
                                        'Are you sure you want to remove $name?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await staffRef.doc(staff.id).delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$name was removed.'),
                                      ),
                                    );
                                  }
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
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStaffDialog(
    BuildContext context,
    String staffId,
    String currentName,
    String currentRole,
    CollectionReference staffRef,
  ) {
    final nameController = TextEditingController(text: currentName);
    final roleController = TextEditingController(text: currentRole);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Staff Member'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter role' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await staffRef.doc(staffId).update({
                  'name': nameController.text.trim(),
                  'role': roleController.text.trim(),
                });
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Staff updated.')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
