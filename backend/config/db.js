// const mongoose = require('mongoose');
// const dotenv = require('dotenv');

// dotenv.config();

// const connectDB = async () => {
//   try {
//     const uri = process.env.MONGO_URI;
//     if (!uri) {
//       throw new Error('MONGO_URI is not defined in environment variables');
//     }
//     const conn = await mongoose.connect(uri, {
//       useNewUrlParser: true,
//       useUnifiedTopology: true,
//     });
//     console.log(`MongoDB connected: ${conn.connection.host}`);
//   } catch (error) {
//     console.error('MongoDB connection error:', error.message);
//     process.exit(1);
//   }
// };

// module.exports = connectDB;



// module.exports = connectDB;


const mongoose = require('mongoose');

const connectDB = async () => {
  const uri = process.env.MONGO_URI;

  if (!uri) {
    throw new Error('MONGO_URI is not defined');
  }

  try {
    console.log('Connecting to MongoDB Atlas...');

    const conn = await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 30000,
      connectTimeoutMS: 30000,
      family: 4
    });

    console.log(
      `MongoDB connected successfully: ${conn.connection.host}`
    );

    return conn;

  } catch (error) {
  console.error("MongoDB connection failed");
  console.error("Name:", error.name);
  console.error("Message:", error.message);

  if (error.reason?.servers) {
    for (const [address, server] of error.reason.servers) {
      console.error("Server:", address);
      console.error("Error:", server.error?.message);
      console.error("Cause:", server.error?.cause);
      console.error("Code:", server.error?.code);
    }
  }

  throw error;
}
};

module.exports = connectDB;