const dotenv = require('dotenv');
const connectDB = require('./config/db');
const app = require('./app');

dotenv.config();
connectDB();

//const PORT = process.env.PORT || 5000;
// app.listen(PORT, () => {
//   console.log(`Server listening on http://localhost:${PORT}`);
// });

const PORT = process.env.PORT || 3000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});
