const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * Cloud Function to automatically populate/update the
 * /supermarkets/{supermarketId}/products subcollection based on
 * new POS transactions.
 *
 * This function triggers when a new document is created in any
 * 'pos_transactions' subcollection. It extracts product details
 * from the transaction and either creates a new product document
 * or updates an existing one in the corresponding 'products'
 * subcollection for that supermarket.
 */
exports.processNewPosTransactionForProducts = functions.firestore
  .document("supermarkets/{supermarketId}/pos_transactions/{transactionId}")
  .onCreate(async (snapshot, context) => {
    const transactionData = snapshot.data();
    const supermarketId = context.params.supermarketId;

    const productSKU = transactionData.sku;
    const productName = transactionData.productName;
    const unitPrice = transactionData.unitPrice;

    // --- Validate crucial data points ---
    if (
      !supermarketId ||
  !transactionData.productId ||
  !productSKU ||
  !productName ||
  unitPrice === undefined
    ) {
      // FIX: Use a single multi-line template literal for clarity and max-len
      console.error(
        `Skipping product update for transaction ${context.params.transactionId}: ` +
      "Missing crucial product data (supermarketId, productId, productSKU, " +
      "productName, unitPrice).",
      );
      return null;
    }

    // Get a reference to the specific supermarket's products subcollection
    const productsCollectionRef = db.collection("supermarkets")
      .doc(supermarketId)
      .collection("products");

    // Attempt to find the product document by its specific productId
    // (from transaction)
    const productDocRef =productsCollectionRef.doc(transactionData.productId);
    const productDocSnapshot = await productDocRef.get();

    const productExists = productDocSnapshot.exists;

    const updatedProductData = {
      name: productName,
      name_lower: productName.toLowerCase(), // For case-insensitive search
      sku: productSKU,
      supermarketId: supermarketId,
      current_price: unitPrice,
      last_sold_at: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (productExists) {
      // Product already exists, update it
      // Breaking the console.log line to adhere to 80 char limit
      console.log(
        `Updating existing product ${transactionData.productId} ` +
            `for supermarket ${supermarketId}.`,
      );
      await productDocRef.update(updatedProductData);
    } else {
      // Product does not exist, create a new one
      // Breaking the console.log line to adhere to 80 char limit
      console.log(
        `Creating new product ${transactionData.productId} ` +
            `for supermarket ${supermarketId}.`,
      );
      updatedProductData.created_at =
          admin.firestore.FieldValue.serverTimestamp();
      await productDocRef.set(updatedProductData);
    }

    return null;
  });
