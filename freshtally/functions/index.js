// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const functions = require("firebase-functions");

// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

// --- Utility Functions (will add more below) ---
// This function will fetch product master data
async function getProductMasterData(productId) {
  const productRef = db.collection("products").doc(productId);
  const productDoc = await productRef.get();
  if (!productDoc.exists) {
    console.warn(`Product master data not found for ProductID: ${productId}`);
    return null;
  }
  return productDoc.data();
}

// This function will calculate and update the aggregated product data
async function updateAggregatedProduct(supermarketId, productId) {
  console.log(`Aggregating data for Supermarket: ${supermarketId}, Product: ${productId}`);

  const productMaster = await getProductMasterData(productId);
  if (!productMaster) {
    console.error(`Skipping aggregation: Product master data missing for ${productId}`);
    return;
  }

  const productName = productMaster.ProductName || "Unknown Product";
  const category = productMaster.category || "Uncategorized"; // Assuming 'category' field in products master
  const sellingPrice = productMaster.sellingPrice || 0; // Assuming 'sellingPrice' field in products master

  // --- 1. Calculate Stock ---
  let totalInitialQuantity = 0;
  // Assuming 'batches' are global and not supermarket-specific for simplicity here.
  // If batches are supermarket-specific (e.g., `batches/BATCHxxxxx` has a `StoreID` field),
  // you would add a .where('StoreID', '==', supermarketId) filter here.
  const batchesSnapshot = await db.collection("batches")
    .where("ProductID", "==", productId)
    .get();

  batchesSnapshot.forEach(doc => {
    totalInitialQuantity += doc.data().InitialQuantity || 0;
  });

  let totalSoldQuantity = 0;
  // Transactions are specific to 'supermarkets/all_transaction_data/transactions' with a 'StoreID' field
  const transactionsSnapshot = await db.collection("supermarkets")
    .doc("all_transaction_data") // Fixed document ID
    .collection("transactions")
    .where("ProductID", "==", productId)
    .where("StoreID", "==", supermarketId)
    .get();

  transactionsSnapshot.forEach(doc => {
    totalSoldQuantity += doc.data().Quantity || 0;
  });

  const currentStock = Math.max(0, totalInitialQuantity - totalSoldQuantity);

  // --- 2. Calculate Sales Velocity (e.g., last 30 days) ---
  const now = new Date();
  const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000); // 30 days in milliseconds

  let totalQuantitySoldLast30Days = 0;
  const daysWithSales = new Set(); // To count unique days with sales, for more accurate velocity if needed

  const recentSalesSnapshot = await db.collection("supermarkets")
    .doc("all_transaction_data")
    .collection("transactions")
    .where("ProductID", "==", productId)
    .where("StoreID", "==", supermarketId)
    .where("TransactionDate", ">=", thirtyDaysAgo.toISOString().substring(0, 10)) // Compare string dates
    .get();

  recentSalesSnapshot.forEach(doc => {
    const data = doc.data();
    totalQuantitySoldLast30Days += data.Quantity || 0;
    daysWithSales.add(data.TransactionDate); // Add date string to set
  });

  // Calculate sales velocity based on the entire 30-day window or actual days with sales
  const salesVelocity = totalQuantitySoldLast30Days / 30; // Using 30 days as fixed window

  // --- 3. Determine Earliest Expiry Date ---
  let earliestExpiryDate = null;
  const activeBatchesSnapshot = await db.collection("batches")
    .where("ProductID", "==", productId)
  // If batches have a 'StoreID' field, filter them:
  // .where('StoreID', '==', supermarketId)
    .get();

  for (const doc of activeBatchesSnapshot.docs) {
    const batchData = doc.data();
    if (batchData.ExpiryDate) {
      const batchExpiryTimestamp = batchData.ExpiryDate;
      const batchExpiryDate = batchExpiryTimestamp.toDate();
      // Only consider batches that are not yet expired
      if (batchExpiryDate.getTime() > now.getTime()) {
        if (earliestExpiryDate === null || batchExpiryDate.getTime() < earliestExpiryDate.getTime()) {
          earliestExpiryDate = batchExpiryDate;
        }
      }
    }
  }

  // --- 4. Update the Aggregated Product Document ---
  const aggregatedProductRef = db.collection("supermarkets")
    .doc(supermarketId)
    .collection("products")
    .doc(productId);

  // Fetch the existing document to retain discount-related fields if they exist
  const existingAggregatedDoc = await aggregatedProductRef.get();
  const existingData = existingAggregatedDoc.exists ? existingAggregatedDoc.data() : {};

  // Prepare data to write/update
  const updateData = {
    productId: productId,
    name: productName,
    category: category,
    price: sellingPrice,
    stock: currentStock,
    salesVelocity: salesVelocity,
    expiryDate: earliestExpiryDate ? admin.firestore.Timestamp.fromDate(earliestExpiryDate) : null,
    // Preserve existing discount fields unless actively changed by AI suggestion logic
    discountPercentage: existingData.discountPercentage || 0,
    discountedPrice: existingData.discountedPrice || sellingPrice,
    aiRecommendedDiscount: existingData.aiRecommendedDiscount || 0,
    lastDiscountUpdate: existingData.lastDiscountUpdate || null,
    aiLastCalculated: existingData.aiLastCalculated || null,
    lastAggregated: admin.firestore.FieldValue.serverTimestamp(), // To track when this was last updated
  };

  await aggregatedProductRef.set(updateData, {merge: true}); // Use merge to avoid overwriting unrelated fields
  console.log(`Aggregated data updated for ${productId} in ${supermarketId}`);
}

// functions/index.js

// ... (initialization and utility functions like getProductMasterData, updateAggregatedProduct) ...

exports.onProductMasterUpdate = functions.firestore
  .document("products/{productId}")
  .onWrite(async (change, context) => {
    const productId = context.params.productId;
    const oldData = change.before.data();
    const newData = change.after.data();

    // Check if relevant fields have changed (ProductName, category, sellingPrice)
    const nameChanged = oldData?.ProductName !== newData?.ProductName;
    const categoryChanged = oldData?.category !== newData?.category;
    const priceChanged = oldData?.sellingPrice !== newData?.sellingPrice;

    if (!nameChanged && !categoryChanged && !priceChanged) {
      console.log(`No relevant changes to product master ${productId}. Skipping aggregation.`);
      return null; // No relevant changes, exit
    }

    console.log(`Product master ${productId} changed. Propagating updates.`);

    // Find all supermarkets that have this product in their batches or transactions
    // This is a complex step. Ideally, you'd have a way to know which supermarkets carry a product.
    // A robust solution might involve a separate collection like `supermarket_products`
    // or iterating through all supermarkets if the number is small.

    // For simplicity, let's assume we can query batches to find affected supermarkets.
    // This query might be expensive if you have many batches.
    const affectedSupermarketIds = new Set();
    const batchesSnapshot = await db.collection("batches")
      .where("ProductID", "==", productId)
      .get();

    batchesSnapshot.forEach(doc => {
      if (doc.data().StoreID) { // Assuming batches have a StoreID field
        affectedSupermarketIds.add(doc.data().StoreID);
      }
    });

    // Also check transactions for all supermarkets that have sold this product
    const allTransactionsSnapshot = await db.collectionGroup("transactions") // Use collectionGroup if 'transactions' is subcollection under many docs
      .where("ProductID", "==", productId)
      .get();

    allTransactionsSnapshot.forEach(doc => {
      if (doc.data().StoreID) {
        affectedSupermarketIds.add(doc.data().StoreID);
      }
    });


    const updatePromises = [];
    for (const smId of affectedSupermarketIds) {
      updatePromises.push(updateAggregatedProduct(smId, productId));
    }

    await Promise.all(updatePromises);
    console.log(`Finished propagating product master updates for ${productId}.`);
    return null;
  });

// functions/index.js

// ... (initialization and utility functions) ...

exports.onBatchChange = functions.firestore
  .document("batches/{batchId}")
  .onWrite(async (change, context) => {
    const oldData = change.before.data();
    const newData = change.after.data();

    let supermarketId;
    let productId;

    if (change.after.exists) { // Document exists after write (create or update)
      supermarketId = newData.StoreID; // Assuming StoreID in batch
      productId = newData.ProductID;
    } else if (change.before.exists) { // Document was deleted
      supermarketId = oldData.StoreID;
      productId = oldData.ProductID;
    } else {
      return null; // Should not happen for onWrite
    }

    if (!supermarketId || !productId) {
      console.warn(`Missing StoreID or ProductID in batch data for ${context.params.batchId}. Cannot aggregate.`);
      return null;
    }

    await updateAggregatedProduct(supermarketId, productId);
    console.log(`Batch ${context.params.batchId} processed for aggregation.`);
    return null;
  });

// functions/index.js

// ... (initialization and utility functions) ...

exports.onTransactionChange = functions.firestore
  .document("supermarkets/all_transaction_data/transactions/{transactionId}")
  .onWrite(async (change, context) => {
    const oldData = change.before.data();
    const newData = change.after.data();

    let supermarketId;
    let productId;

    if (change.after.exists) { // Document exists after write (create or update)
      supermarketId = newData.StoreID;
      productId = newData.ProductID;
    } else if (change.before.exists) { // Document was deleted
      supermarketId = oldData.StoreID;
      productId = oldData.ProductID;
    } else {
      return null; // Should not happen for onWrite
    }

    if (!supermarketId || !productId) {
      console.warn(`Missing StoreID or ProductID in transaction data for ${context.params.transactionId}. Cannot aggregate.`);
      return null;
    }

    await updateAggregatedProduct(supermarketId, productId);
    console.log(`Transaction ${context.params.transactionId} processed for aggregation.`);
    return null;
  });

  const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.notifyExpiringPromotions = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    const now = new Date();
    const twoDaysLater = new Date(now);
    twoDaysLater.setDate(now.getDate() + 2);

    const productsRef = admin.firestore().collection("products");
    const snapshot = await productsRef
      .where("discountExpiry", ">=", now)
      .where("discountExpiry", "<=", twoDaysLater)
      .get();

    const batch = admin.firestore().batch();

    snapshot.forEach((doc) => {
      const data = doc.data();
      const notificationRef = admin.firestore().collection("notifications").doc();

      batch.set(notificationRef, {
        type: "promo_expiry",
        title: "Discount Ending Soon",
        message: `Promotion on ${data.name} is about to expire.`,
        supermarketName: data.supermarketName ?? "Unknown",
        createdAt: admin.firestore.Timestamp.now(),
        read: false,
        payload: {
          productId: doc.id,
          productName: data.name,
          expiryDate: data.discountExpiry,
          discountPercentage: data.discountPercentage,
        },
      });
    });

    if (!snapshot.empty) {
      await batch.commit();
      console.log(`Created ${snapshot.size} promotion expiry notifications.`);
    } else {
      console.log("No expiring promotions found.");
    }

    return null;
  });
