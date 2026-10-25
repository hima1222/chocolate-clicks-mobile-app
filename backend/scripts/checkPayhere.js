require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const mongoose = require('mongoose');
const { config } = require('../services/payhereService');
async function main() {
  let ready = true;
  for (const key of ['PAYHERE_MERCHANT_ID', 'PAYHERE_MERCHANT_SECRET']) {
    const present = Boolean(process.env[key]?.trim());
    console.log(`${key}: ${present ? 'set' : 'missing'}`);
    if (!present) ready = false;
  }
  try { const c = config(); console.log(`PayHere configuration: ready (${c.sandbox ? 'sandbox' : 'live'})`); }
  catch (error) { console.log(error.message); ready = false; }
  if (!process.env.MONGO_URI) { console.log('MongoDB: MONGO_URI is missing'); ready = false; }
  else {
    try {
      await mongoose.connect(process.env.MONGO_URI, { serverSelectionTimeoutMS: 10000 });
      const hello = await mongoose.connection.db.admin().command({ hello: 1 });
      const transactions = Boolean(hello.setName || hello.msg === 'isdbgrid');
      console.log(`MongoDB: ${transactions ? 'product and event payments supported' : 'product payments supported; event payments need a replica set'}`);
      const Product = require('../models/Product');
      const count = await Product.countDocuments();
      console.log(`Product catalog: ${count} products${count ? '' : ' (run npm run seed:products)'}`);
      if (!count) ready = false;
    } catch (_) { console.log('MongoDB: connection check failed; check connectivity and MONGO_URI'); ready = false; }
    finally { await mongoose.disconnect(); }
  }
  console.log(`Receipt email: ${process.env.SMTP_HOST ? 'configured (delivery not tested)' : 'not configured'}`);
  if (!ready) process.exitCode = 1;
}
main().catch(() => { console.error('Configuration check failed.'); process.exitCode = 1; });
