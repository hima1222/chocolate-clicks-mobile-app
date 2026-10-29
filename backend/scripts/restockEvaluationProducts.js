require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const mongoose = require('mongoose');
const { randomInt } = require('crypto');
const Product = require('../models/Product');
const catalog = require('../seeds/products.json');
async function main() {
  await mongoose.connect(process.env.MONGO_URI, { serverSelectionTimeoutMS: 10000 });
  const before = await Product.find().select('name quantity').lean();
  console.log(`Before: ${before.length} products, ${before.filter(p => !(p.quantity > 0)).length} without stock.`);
  if (!process.argv.includes('--apply')) return;
  for (const product of catalog) {
    await Product.updateOne({ name: product.name }, { $setOnInsert: require('../utils/resolveImages')(product) }, { upsert: true });
  }
  const products = await Product.find().select('_id');
  await Product.bulkWrite(products.map(product => ({ updateOne: {
    filter: { _id: product._id }, update: { $set: { quantity: randomInt(10, 51) } }
  } })));
  const saved = await Product.find().select('name quantity').lean();
  console.log(JSON.stringify(saved.map(({ name, quantity }) => ({ name, quantity })), null, 2));
  console.log(`Verified: ${saved.length} products, ${saved.filter(p => p.quantity > 0).length} in stock.`);
}
main().catch(error => { console.error(`Stock update failed (${error.name}). Check database connectivity.`); process.exitCode = 1; }).finally(() => mongoose.disconnect());
