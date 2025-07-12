import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a 6-digit verification code for staff signup
  static Future<String> generateCode({
    required String supermarketName,
    required String staffName,
  }) async {
    // Generate a 6-digit code
    String code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString();

    // Store the verification code
    await _firestore.collection('verification_codes').add({
      'code': code,
      'supermarketName': supermarketName,
      'staffName': staffName,
      'isUsed': false,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': FieldValue.serverTimestamp(), // Add expiration logic if needed
    });

    // Create a notification for tracking
    await _firestore.collection('notifications').add({
      'type': 'code_generated',
      'title': 'Verification Code Generated',
      'message':
          'A verification code was generated for $staffName to join $supermarketName.',
      'payload': {
        'verificationCode': code,
        'staffName': staffName,
        'supermarketName': supermarketName,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    return code;
  }

  /// Verify a 6-digit code for staff signup
  static Future<bool> verifyCode({
    required String code,
    required String supermarketName,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('verification_codes')
          .where('code', isEqualTo: code)
          .where('supermarketName', isEqualTo: supermarketName)
          .where('isUsed', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      // Mark the code as used
      await querySnapshot.docs.first.reference.update({'isUsed': true});
      return true;
    } catch (e) {
      print('Error verifying code: $e');
      return false;
    }
  }

  /// Get recent verification codes for a supermarket
  static Future<List<Map<String, dynamic>>> getRecentCodes({
    required String supermarketName,
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('verification_codes')
          .where('supermarketName', isEqualTo: supermarketName)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'code': doc.data()['code'],
                'staffName': doc.data()['staffName'],
                'isUsed': doc.data()['isUsed'] ?? false,
                'createdAt': doc.data()['createdAt'],
              })
          .toList();
    } catch (e) {
      print('Error loading recent codes: $e');
      return [];
    }
  }

  /// Check if a supermarket exists
  static Future<bool> supermarketExists(String supermarketName) async {
    try {
      final querySnapshot = await _firestore
          .collection('supermarkets')
          .where('name', isEqualTo: supermarketName)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking supermarket existence: $e');
      return false;
    }
  }

  /// Create a staff account after successful verification
  static Future<bool> createStaffAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String supermarketName,
    required String role,
    required String verificationCode,
  }) async {
    try {
      await _firestore.collection('staff').add({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'supermarketName': supermarketName,
        'role': role,
        'verificationCode': verificationCode,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return true;
    } catch (e) {
      print('Error creating staff account: $e');
      return false;
    }
  }
} 