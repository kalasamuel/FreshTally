import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class PromotionModel {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
      print('Model loaded successfully!');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  // Method to predict discount
  int predictDiscount({
    required int daysToExpiry,
    required double salesVelocity,
    required int stock,
    required String category,
  }) {
    if (_interpreter == null) {
      print("Model not loaded. Please call loadModel() first.");
      return 0; // Return a default or error value
    }

    // Example: Prepare input for the model
    // You'll need to map your category string to a numerical representation
    // (e.g., one-hot encoding or label encoding, depending on how your model was trained).
    // For simplicity, let's assume 'Dairy' is 0, 'Baked Goods' is 1, etc.
    int categoryEncoded;
    switch (category.toLowerCase()) {
      case 'dairy':
        categoryEncoded = 0;
        break;
      case 'baked goods':
        categoryEncoded = 1;
        break;
      case 'beverages':
        categoryEncoded = 2;
        break;
      case 'produce':
        categoryEncoded = 3;
        break;
      case 'canned goods':
        categoryEncoded = 4;
        break;
      case 'snacks':
        categoryEncoded = 5;
        break;
      default:
        categoryEncoded = -1; // Handle unknown categories
    }

    // Ensure your input shape matches your model's expected input shape
    // For example, if your model expects [1, 4] for 4 features
    var input = Float32List.fromList([
      daysToExpiry.toDouble(),
      salesVelocity,
      stock.toDouble(),
      categoryEncoded.toDouble(),
    ]).reshape([1, 4]); // Reshape to match model input

    // Output tensor shape (e.g., [1, 1] for a single discount prediction)
    var output = Float32List(1).reshape([1, 1]);

    try {
      _interpreter!.run(input, output);
      // Assuming the model outputs a float that represents the discount percentage
      int predictedDiscount = output[0][0].round();
      return predictedDiscount.clamp(5, 50); // Clamp as per your business logic
    } catch (e) {
      print("Error running inference: $e");
      return 0;
    }
  }

  // Method to predict associated products (conceptual)
  // This part highly depends on how your recommendation model is structured.
  // It might involve another TFLite model or a separate API call if it's a larger model.
  List<String> predictAssociatedProducts(String productName) {
    // For a simple TFLite model, you might have it output a fixed-size embedding
    // and then perform a similarity search in Flutter, or have it output indices
    // of recommended products which you then map to names.
    // For now, we'll keep the static mapping as a placeholder until your ML model
    // provides this functionality directly.
    final Map<String, List<String>> _staticProductSuggestions = {
      'Organic Milk (1L)': ['Cereal', 'Coffee Powder', 'Sugar'],
      'Artisan Bread': ['Butter', 'Jam', 'Cheese'],
      'Premium Coffee Beans': ['Coffee Maker', 'Milk Frother', 'Sugar'],
      'Fresh Strawberries': ['Yogurt', 'Whipped Cream', 'Pancake Mix'],
      'Canned Tuna': ['Mayonnaise', 'Bread', 'Salad Greens'],
      'Assorted Chocolates': ['Wine', 'Flowers', 'Gift Wrap'],
    };
    return _staticProductSuggestions[productName] ?? [];
  }

  void dispose() {
    _interpreter?.close();
  }
}
