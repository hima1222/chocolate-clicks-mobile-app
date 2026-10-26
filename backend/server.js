// const dotenv = require('dotenv');
// dotenv.config();
// const connectDB = require('./config/db');
// const app = require('./app');

// async function start() {
//   await connectDB();
//   // Unique indexes must exist before accepting payments.
//   await Promise.all([
//     require('./models/Order').init(), require('./models/Booking').init(),
//     require('./models/PaymentReceipt').init(),
//   ]);
//   require('./services/receiptService').startReceiptWorker();
//   const port = process.env.PORT || 5000;
//   app.listen(port, '0.0.0.0', () => console.log(`Server running on port ${port}`));
// }
// start().catch((error) => { console.error(error.message); process.exit(1); });

require('dotenv').config();

const connectDB = require('./config/db');
const app = require('./app');

const net = require('node:net');
const dns = require('node:dns').promises;

async function testMongoNetwork() {
  const host = 'ac-qimc7ot-shard-00-00.uwmr2zf.mongodb.net';

  try {
    const addresses = await dns.lookup(host, { all: true });
    console.log('MongoDB DNS:', addresses);
  } catch (err) {
    console.error('MongoDB DNS failed:', err.message);
  }

  const socket = net.connect({
    host,
    port: 27017,
    timeout: 10000
  });

  socket.on('connect', () => {
    console.log('MongoDB TCP port 27017 reachable');
    socket.destroy();
  });

  socket.on('timeout', () => {
    console.error('MongoDB TCP connection timed out');
    socket.destroy();
  });

  socket.on('error', (err) => {
    console.error('MongoDB TCP error:', err.code, err.message);
  });
}

testMongoNetwork();

async function start() {
  try {
    console.log('Starting Chocolate Clicks Backend...');

    console.log('MONGO_URI configured:', Boolean(process.env.MONGO_URI));

    console.log('Connecting to MongoDB...');
    await connectDB();

    console.log('MongoDB connection established.');

    console.log('Initializing database indexes...');
    await Promise.all([
      require('./models/Order').init(),
      require('./models/Booking').init(),
      require('./models/PaymentReceipt').init(),
    ]);

    console.log('Database indexes initialized.');

    require('./services/receiptService').startReceiptWorker();

    const port = process.env.PORT || 5000;

    app.listen(port, '0.0.0.0', () => {
      console.log(`Server running on port ${port}`);
    });

  } catch (error) {
    console.error('Backend startup failed');
    console.error('Error name:', error.name);
    console.error('Error message:', error.message);
    console.error('Error cause:', error.cause);
    console.error('Server selection details:', error.reason);

    process.exit(1);
  }
}

start();