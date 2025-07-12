import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class StaffCodeGenerationPage extends StatefulWidget {
  final String supermarketName;
  final String location;

  const StaffCodeGenerationPage({
    Key? key,
    required this.supermarketName,
    required this.location,
  }) : super(key: key);

  @override
  State<StaffCodeGenerationPage> createState() => _StaffCodeGenerationPageState();
}

class _StaffCodeGenerationPageState extends State<StaffCodeGenerationPage> {
  final TextEditingController _staffNameController = TextEditingController();
  String? _generatedCode;
  bool _isGenerating = false;
  List<Map<String, dynamic>> _recentCodes = [];

  @override
  void initState() {
    super.initState();
    _loadRecentCodes();
  }

  @override
  void dispose() {
    _staffNameController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentCodes() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('verification_codes')
          .where('supermarketName', isEqualTo: widget.supermarketName)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      setState(() {
        _recentCodes = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'code': doc.data()['code'],
                  'staffName': doc.data()['staffName'],
                  'isUsed': doc.data()['isUsed'] ?? false,
                  'createdAt': doc.data()['createdAt'],
                })
            .toList();
      });
    } catch (e) {
      print('Error loading recent codes: $e');
    }
  }

  Future<void> _generateCode() async {
    if (_staffNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the staff member\'s name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Generate a 6-digit code
      String code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
          .toString();

      // Store the verification code
      await FirebaseFirestore.instance.collection('verification_codes').add({
        'code': code,
        'supermarketName': widget.supermarketName,
        'staffName': _staffNameController.text.trim(),
        'isUsed': false,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': FieldValue.serverTimestamp(), // Add expiration logic if needed
      });

      // Create a notification for tracking
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'code_generated',
        'title': 'Verification Code Generated',
        'message':
            'A verification code was generated for ${_staffNameController.text.trim()} to join ${widget.supermarketName}.',
        'payload': {
          'verificationCode': code,
          'staffName': _staffNameController.text.trim(),
          'supermarketName': widget.supermarketName,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      setState(() {
        _generatedCode = code;
        _isGenerating = false;
      });

      // Clear the staff name field
      _staffNameController.clear();

      // Reload recent codes
      await _loadRecentCodes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Staff Code'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Supermarket Info
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.supermarketName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.location,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Generate Code Section
              const Text(
                'Generate Verification Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter the staff member\'s name and generate a 6-digit verification code for them to use during signup.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Staff Name Input
              TextField(
                controller: _staffNameController,
                decoration: InputDecoration(
                  labelText: 'Staff Member Name',
                  hintText: 'Enter the staff member\'s full name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),

              // Generate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Generate Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              // Generated Code Display
              if (_generatedCode != null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  color: const Color(0xFFE8F5E8),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Generated Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _generatedCode!,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () => _copyCode(_generatedCode!),
                                icon: const Icon(Icons.copy, color: Colors.green),
                                tooltip: 'Copy code',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Share this code with the staff member for signup',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Recent Codes Section
              const Text(
                'Recent Codes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              if (_recentCodes.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No codes generated yet',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentCodes.length,
                  itemBuilder: (context, index) {
                    final code = _recentCodes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          code['staffName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Code: ${code['code']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: code['isUsed']
                                    ? Colors.grey[300]
                                    : Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                code['isUsed'] ? 'Used' : 'Active',
                                style: TextStyle(
                                  color: code['isUsed']
                                      ? Colors.grey[600]
                                      : Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!code['isUsed'])
                              IconButton(
                                onPressed: () => _copyCode(code['code']),
                                icon: const Icon(Icons.copy, size: 20),
                                tooltip: 'Copy code',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
} 