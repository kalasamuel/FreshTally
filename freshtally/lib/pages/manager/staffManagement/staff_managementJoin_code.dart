import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ManageStaffPage extends StatefulWidget {
  final String supermarketId;

  const ManageStaffPage({super.key, required this.supermarketId});

  @override
  State<ManageStaffPage> createState() => _ManageStaffPageState();
}

class _ManageStaffPageState extends State<ManageStaffPage> {
  late DocumentReference joinCodeRef;
  late CollectionReference staffRef;
  static const validityMinutes = 10;

  @override
  void initState() {
    super.initState();

    joinCodeRef = FirebaseFirestore.instance
        .collection('supermarkets')
        .doc(widget.supermarketId)
        .collection('meta')
        .doc('join_code');

    staffRef = FirebaseFirestore.instance
        .collection('supermarkets')
        .doc(widget.supermarketId)
        .collection('staff');
  }

  /// Generates a random 6-digit numeric code
  String _generateJoinCode() {
    final rand = Random.secure();
    return (100000 + rand.nextInt(900000)).toString(); // always 6 digits
  }

  /// Saves the new join code to Firestore with expiry
  Future<void> _setJoinCode() async {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: validityMinutes));
    final code = _generateJoinCode();

    await joinCodeRef.set({
      'code': code,
      'createdAt': now,
      'expiresAt': expiresAt,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('New join code generated: $code')));

    setState(() {}); // Refresh FutureBuilder
  }

  Future<bool> _canGenerateNewCode(DocumentSnapshot? data) async {
    if (data == null || !data.exists) return true;

    final expiresAtTimestamp = data['expiresAt'];
    if (expiresAtTimestamp == null) return true;

    final expiresAt = (expiresAtTimestamp as Timestamp).toDate();
    return DateTime.now().isAfter(expiresAt);
  }

  String _formatTime(DateTime dt) {
    return DateFormat.Hm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Staff')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Staff Join Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                FutureBuilder<DocumentSnapshot>(
                  future: joinCodeRef.get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }

                    return ElevatedButton.icon(
                      onPressed: () async {
                        final canGenerate = await _canGenerateNewCode(
                          snapshot.data,
                        );
                        if (!canGenerate) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Current code is still valid. Try later.',
                              ),
                            ),
                          );
                        } else {
                          await _setJoinCode();
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Generate'),
                    );
                  },
                ),
              ],
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

                final data = snapshot.data!;
                final code = data['code'] ?? 'N/A';
                final expiresAt = data['expiresAt'] != null
                    ? (data['expiresAt'] as Timestamp).toDate()
                    : null;

                final isExpired =
                    expiresAt != null && DateTime.now().isAfter(expiresAt);

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Join Code: $code',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (expiresAt != null)
                        Text(
                          isExpired
                              ? 'Code expired'
                              : 'Valid until ${_formatTime(expiresAt)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isExpired ? Colors.red : Colors.green,
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (!isExpired)
                        QrImageView(
                          data: code,
                          size: 120,
                          backgroundColor: Colors.white,
                        ),
                    ],
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
                                    if (!mounted) return;
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
                if (!mounted) return;
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
