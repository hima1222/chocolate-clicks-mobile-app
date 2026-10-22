const dotenv = require('dotenv');
dotenv.config();
const connectDB = require('./config/db');
const app = require('./app');

async function start() {
  await connectDB();
  // Unique indexes must exist before accepting payments.
  await Promise.all([
    require('./models/Order').init(), require('./models/Booking').init(),
    require('./models/PaymentReceipt').init(),
  ]);
  require('./services/receiptService').startReceiptWorker();
  const port = process.env.PORT || 3000;
  app.listen(port, '0.0.0.0', () => console.log(`Server running on port ${port}`));
}
start().catch((error) => { console.error(error.message); process.exit(1); });
