// lib/core/services/firestore_service.dart
import 'dart:convert'; // Needed for jsonDecode
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Used to check if running on web
import 'package:your_app_name/models/product_model.dart'; // Adjust this import based on your actual structure

/// A service class to handle all Firestore database operations.
/// This class is implemented as a singleton to ensure a single instance
/// manages Firebase connections throughout the application.
class FirestoreService {
  // Late initialization for Firebase instances, they will be set up during initializeFirebase.
  late FirebaseFirestore _db;
  late FirebaseAuth _auth;

  // Variables provided by the Canvas environment for Firebase setup and authentication.
  late String _appId;
  String? _userId; // Stores the current user's UID, nullable until authenticated.

  // Flag to prevent multiple initializations of Firebase.
  bool _isInitialized = false;

  // Private constructor for the singleton pattern.
  FirestoreService._privateConstructor();

  // The single instance of FirestoreService.
  static final FirestoreService _instance = FirestoreService._privateConstructor();

  /// Returns the singleton instance of FirestoreService.
  factory FirestoreService() => _instance;

  /// Initializes Firebase and sets up authentication.
  /// This method must be called once at the start of the application's lifecycle,
  /// ideally in `main.dart` or a root widget's `initState`.
  Future<void> initializeFirebase() async {
    // Prevent re-initialization if already done.
    if (_isInitialized) {
      print('FirestoreService already initialized.');
      return;
    }

    try {
      // Access global variables provided by the Canvas environment.
      // These variables are injected into the web environment (kIsWeb).
      // For non-web platforms or if variables are undefined, fall back to defaults.
      _appId = kIsWeb && typeof __app_id !== 'undefined'
          ? __app_id
          : 'default-app-id'; // Use provided app ID or a default

      final firebaseConfig = kIsWeb && typeof __firebase_config !== 'undefined'
          ? Map<String, dynamic>.from(jsonDecode(__firebase_config))
          : {}; // Use provided Firebase config or an empty map

      // Initialize Firebase app if it hasn't been initialized yet.
      // This is crucial for connecting to your specific Firebase project.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: FirebaseOptions.fromMap(firebaseConfig));
        print('Firebase app initialized with provided config.');
      } else {
        print('Firebase app already initialized.');
      }

      // Get instances of Firestore and FirebaseAuth.
      _db = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;

      // Listen for authentication state changes.
      // This listener ensures that _userId is always updated based on the current user.
      _auth.authStateChanges().listen((User? user) async {
        if (user == null) {
          // If no user is signed in, attempt to sign in using the custom token
          // provided by the Canvas environment. If that fails or isn't available,
          // fall back to anonymous sign-in.
          if (kIsWeb && typeof __initial_auth_token !== 'undefined' && __initial_auth_token.isNotEmpty) {
            try {
              await _auth.signInWithCustomToken(__initial_auth_token);
              _userId = _auth.currentUser?.uid;
              print('Signed in with custom token: $_userId');
            } catch (e) {
              print('Error signing in with custom token: $e');
              // Fallback to anonymous sign-in if custom token fails.
              await _auth.signInAnonymously();
              _userId = _auth.currentUser?.uid;
              print('Signed in anonymously after token failure: $_userId');
            }
          } else {
            // If not on web or no initial token, sign in anonymously.
            await _auth.signInAnonymously();
            _userId = _auth.currentUser?.uid;
            print('Signed in anonymously: $_userId');
          }
        } else {
          // If a user is already signed in, update _userId.
          _userId = user.uid;
          print('User signed in: $_userId');
        }
      });

      _isInitialized = true; // Mark the service as initialized.
      print('FirestoreService initialized successfully.');
    } catch (e) {
      print('Error initializing Firebase: $e');
      // Re-throw the error to indicate initialization failure to the caller.
      rethrow;
    }
  }

  /// Returns the current user ID.
  /// Provides a fallback anonymous ID if the user is not yet authenticated.
  String get currentUserId => _userId ?? 'anonymous_user_${DateTime.now().millisecondsSinceEpoch}';

  /// Returns the Firestore collection reference for products.
  /// Products are stored in a public collection accessible by all users within the app.
  /// The path is `artifacts/{appId}/public/data/products`.
  CollectionReference<Map<String, dynamic>> get _productsCollection {
    _ensureInitialized(); // Ensure Firebase is initialized before accessing collections.
    return _db.collection('artifacts').doc(_appId).collection('public').doc('data').collection('products');
  }

  /// Ensures Firebase is initialized before any Firestore operation is performed.
  /// Throws an exception if not initialized.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('FirestoreService is not initialized. Call initializeFirebase() first.');
    }
  }

  /// Fetches a stream of all products from Firestore.
  /// Returns a real-time stream that updates whenever product data changes.
  /// Includes error handling for individual document parsing.
  Stream<List<Product>> getProducts() {
    try {
      return _productsCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            return Product.fromFirestore(doc);
          } catch (e) {
            print('Error parsing product document ${doc.id}: $e');
            return null; // Return null for documents that fail to parse
          }
        }).where((product) => product != null).cast<Product>().toList(); // Filter out nulls and cast
      });
    } catch (e) {
      print('Error getting products stream: $e');
      return Stream.value([]); // Return an empty stream on error
    }
  }

  /// Adds a new product to Firestore.
  /// Returns `true` on success, `false` on failure.
  Future<bool> addProduct(Product product) async {
    try {
      _ensureInitialized();

      // Add server timestamps and user tracking for auditing.
      Map<String, dynamic> productData = product.toFirestore();
      productData['createdAt'] = FieldValue.serverTimestamp();
      productData['updatedAt'] = FieldValue.serverTimestamp();
      productData['createdBy'] = currentUserId;

      await _productsCollection.add(productData);
      print('Product added: ${product.name}');
      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  /// Updates an existing product in Firestore.
  /// Requires the product to have a valid `id`. Returns `true` on success, `false` on failure.
  Future<bool> updateProduct(Product product) async {
    try {
      _ensureInitialized();

      if (product.id.isEmpty) { // Check for empty ID instead of null for safety
        print('Error: Product ID is required for update');
        return false;
      }

      // Add server timestamp and user tracking for updates.
      Map<String, dynamic> productData = product.toFirestore();
      productData['updatedAt'] = FieldValue.serverTimestamp();
      productData['updatedBy'] = currentUserId;

      await _productsCollection.doc(product.id).update(productData);
      print('Product updated: ${product.name}');
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  /// Deletes a product from Firestore by its ID.
  /// Returns `true` on success, `false` on failure.
  Future<bool> deleteProduct(String productId) async {
    try {
      _ensureInitialized();

      if (productId.isEmpty) {
        print('Error: Product ID cannot be empty for deletion');
        return false;
      }

      await _productsCollection.doc(productId).delete();
      print('Product deleted: $productId');
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  /// Gets a single product by its ID from Firestore.
  /// Returns the `Product` object if found, `null` otherwise.
  Future<Product?> getProductById(String productId) async {
    try {
      _ensureInitialized();

      if (productId.isEmpty) {
        print('Error: Product ID cannot be empty for fetching by ID');
        return null;
      }

      DocumentSnapshot doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product by ID: $e');
      return null;
    }
  }

  /// Searches for products by name in Firestore.
  /// Performs a case-sensitive prefix search.
  Future<List<Product>> searchProducts(String query) async {
    try {
      _ensureInitialized();

      if (query.isEmpty) {
        return []; // Return empty list if query is empty
      }

      // Firestore query for prefix matching (case-sensitive).
      // For case-insensitive or more complex search, consider client-side filtering
      // after fetching a broader set, or using a dedicated search service.
      QuerySnapshot snapshot = await _productsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff') // Unicode character for end of string
          .get();

      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      return []; // Return empty list on error
    }
  }

  /// Disposes of any resources held by the service.
  /// In a singleton, this might be called when the app is shutting down.
  void dispose() {
    // No explicit streams or listeners in this class that need manual cancellation
    // beyond what Firebase SDK handles automatically on app shutdown.
    print('FirestoreService disposed');
  }
}
