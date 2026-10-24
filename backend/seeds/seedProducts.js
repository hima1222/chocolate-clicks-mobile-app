require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const mongoose = require('mongoose');
const Product = require('../models/Product');
const products = require('./products.json');
async function main() {
  if (!process.env.MONGO_URI) throw new Error('MONGO_URI is required');
  await mongoose.connect(process.env.MONGO_URI, { serverSelectionTimeoutMS: 10000 });
  let added = 0;
  for (const product of products) {
    const result = await Product.updateOne({ name: product.name }, { $setOnInsert: product }, { upsert: true });
    added += result.upsertedCount;
  }
  console.log(`Product catalog ready: ${added} missing products added. Existing prices were preserved.`);
}
main().catch(() => { console.error('Product seeding failed. Check MongoDB connectivity and permissions.'); process.exitCode = 1; })
  .finally(() => mongoose.disconnect());
