# Chocolate Clicks Backend

This backend provides an Express API server for the Chocolate Clicks Flutter app.
It uses MongoDB Atlas, Mongoose, JWT authentication, bcrypt password hashing, cors, and dotenv.

## Backend folder structure

backend/
├── config/
│   └── db.js               # MongoDB connection
├── controllers/
│   ├── authController.js   # Register, login, profile
│   ├── productController.js
│   ├── orderController.js
│   ├── eventController.js
│   └── bookingController.js
├── middleware/
│   ├── authMiddleware.js   # Protect routes
│   └── errorMiddleware.js  # Error handler
├── models/
│   ├── User.js
│   ├── Product.js
│   ├── Order.js
│   ├── Event.js
│   └── Booking.js
├── routes/
│   ├── authRoutes.js
│   ├── productRoutes.js
│   ├── orderRoutes.js
│   ├── eventRoutes.js
│   └── bookingRoutes.js
├── utils/
│   └── generateToken.js
├── .env.example
├── package.json
└── server.js

## Install and run

1. Open a terminal in `backend/`
2. Copy `.env.example` to `.env`
3. Set your MongoDB Atlas connection string and JWT secret in `.env`

```env
PORT=5000
MONGO_URI=your_mongodb_atlas_connection_string
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=7d
```

4. Install dependencies:

```bash
npm install
```

5. Start the server:

```bash
npm run dev
```

6. The API should be available at `http://localhost:5000`

## Important API routes

### Authentication
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `PUT /api/auth/profile`

### Products
- `GET /api/products`
- `GET /api/products/search?q=chocolate`
- `GET /api/products/category/:categoryId`
- `GET /api/products/:id`
- `POST /api/products`

### Orders
- `POST /api/orders`
- `GET /api/orders`
- `GET /api/orders/:id`
- `PUT /api/orders/:id/cancel`

### Events
- `GET /api/events`
- `GET /api/events/:id`
- `POST /api/events`

### Bookings
- `POST /api/bookings`
- `GET /api/bookings`
- `GET /api/bookings/:id`

## Flutter integration guidance

1. Set your Flutter app `ApiClient.baseUrl` to your backend URL.
   - For Android emulator: `http://10.0.2.2:5000/api`
   - For iOS simulator or web: `http://localhost:5000/api`

2. Send `Authorization: Bearer <token>` headers for protected routes.
3. Use the backend endpoints for user registration, login, profile, products, orders, events, and bookings.

## Notes

- `authRoutes` uses JWT to protect user routes.
- `orderRoutes` and `bookingRoutes` require login.
- `createOrder` expects item objects like:
  `[{ productId: '...', quantity: 2 }]`

If you want, I can also help wire the Flutter services to the backend API routes directly. 
