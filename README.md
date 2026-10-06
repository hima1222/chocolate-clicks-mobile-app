# Chocolate Clicks

Chocolate Clicks is a Flutter application for browsing baked goods, managing a shopping cart, exploring events and workshops, and following a checkout flow. A Node.js and Express API provides authentication, product listings, orders, events, and bookings backed by MongoDB.

## Contents

- [Features](#features)
- [Technology stack](#technology-stack)
- [Project structure](#project-structure)
- [Local setup](#local-setup)
- [API reference](#api-reference)
- [Development and testing](#development-and-testing)
- [Current implementation status](#current-implementation-status)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Features

- Account registration, login, profile viewing, and profile editing.
- Baked-goods browsing, including cakes, brownies, and cookies.
- Product search, favorites, and shopping-cart screens.
- Event discovery, workshops, and booking flows.
- Checkout screens for card, UPI, digital wallet, and bank transfer methods.
- Card entry with a 16-digit card-number limit, `MM/YY` expiry formatting, a 3-digit CVV, and a toggleable save-card preference.
- Payment summary, success, and failure screens.
- Notification and message screens.

Some features use local or simulated data. See [Current implementation status](#current-implementation-status) for integration limits.

## Technology stack

| Layer | Technologies |
| --- | --- |
| Frontend | Flutter, Dart, Material widgets |
| HTTP communication | Dart `http` package |
| Local storage | `shared_preferences` |
| Backend | Node.js, Express |
| Database | MongoDB, Mongoose |
| Authentication | JSON Web Tokens, bcrypt password hashing |
| Backend development | nodemon, dotenv, cors |
| Frontend tests | `flutter_test`, Flutter lints |

## Project structure

```text
chocolate_clicks/
|-- README.md                  # Project overview and setup
|-- frontend/                  # Flutter application
|   |-- lib/
|   |   |-- main.dart          # Application entry point
|   |   |-- app.dart           # App configuration and navigation
|   |   |-- models/            # User, product, order, and other models
|   |   |-- screens/           # Authentication, catalog, events, checkout
|   |   |-- services/          # API, session, storage, and feature services
|   |   `-- widgets/           # Shared UI components
|   |-- assets/images/         # App images
|   |-- test/                  # Widget and card-form regression tests
|   `-- pubspec.yaml           # Flutter dependencies and assets
|-- backend/
|   |-- config/                # Database connection
|   |-- controllers/           # Request handlers
|   |-- middleware/            # JWT protection and error handling
|   |-- models/                # Mongoose schemas
|   |-- routes/                # API route definitions
|   |-- utils/                 # Token generation
|   |-- package.json           # Node dependencies and scripts
|   `-- server.js              # Express server entry point
`-- .gitignore
```

Platform and generated build folders also exist at the repository root. Run Flutter commands from `frontend/`, which contains the application's `pubspec.yaml`.

## Local setup

### Prerequisites

- Flutter with a bundled Dart SDK compatible with `^3.10.7`, as declared in `frontend/pubspec.yaml`.
- Node.js and npm.
- A MongoDB database, either local or hosted through MongoDB Atlas.
- Chrome for web development, or a configured Android/iOS development environment.

Check your Flutter environment:

```bash
flutter doctor
```

### 1. Get the project

Clone this repository using its GitHub clone URL, then open the repository directory. The following steps assume your terminal starts at the project root.

### 2. Configure the backend

Create `backend/.env` with the following values:

```dotenv
PORT=5000
MONGO_URI=mongodb://127.0.0.1:27017/chocolate_clicks
JWT_SECRET=replace_with_a_long_random_secret
JWT_EXPIRES_IN=7d
```

| Variable | Purpose |
| --- | --- |
| `PORT` | API server port; defaults to `5000` |
| `MONGO_URI` | MongoDB connection string; replace the local example with your Atlas URI if needed |
| `JWT_SECRET` | Secret used to sign authentication tokens |
| `JWT_EXPIRES_IN` | Token expiration setting, such as `7d` |

Keep real credentials in `.env`; the repository ignores this file.

Install and start the backend:

```bash
cd backend
npm ci
npm run dev
```

For startup without nodemon:

```bash
npm start
```

Open `http://localhost:5000/` to check the server response:

```json
{
  "success": true,
  "message": "Chocolate Clicks API is running"
}
```

This checks the HTTP server; also check the terminal for database connection errors.

### 3. Configure the frontend API URL

Edit `ApiClient.baseUrl` in [`frontend/lib/services/api_client.dart`](frontend/lib/services/api_client.dart). Include the `/api` suffix.

| Run target | Backend URL |
| --- | --- |
| Chrome on the backend computer | `http://localhost:5000/api` |
| Android emulator | `http://10.0.2.2:5000/api` |
| iOS simulator with backend on the same Mac | `http://localhost:5000/api` |
| Physical device on the same network | `http://<backend-computer-LAN-IP>:5000/api` |

The current default is `http://localhost:5000/api`. Update the port if you changed `PORT`. For a physical device, allow inbound connections to the backend port through the host firewall.

### 4. Run the frontend

Open a second terminal at the project root:

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

For a connected device or emulator:

```bash
flutter devices
flutter run
```

Keep the backend running while using API-backed features.

## API reference

All routes below are relative to `http://localhost:5000`. Protected routes require:

```http
Authorization: Bearer <token>
```

| Method | Endpoint | Purpose | JWT required |
| --- | --- | --- | --- |
| GET | `/` | Server status | No |
| POST | `/api/auth/register` | Register an account | No |
| POST | `/api/auth/login` | Log in | No |
| GET | `/api/auth/me` | Get current user | Yes |
| PUT | `/api/auth/profile` | Update current profile | Yes |
| GET | `/api/products` | List products | No |
| GET | `/api/products/search?q=chocolate` | Search products | No |
| GET | `/api/products/category/:categoryId` | List products by category | No |
| GET | `/api/products/:id` | Get a product | No |
| POST | `/api/products` | Create a product | No |
| POST | `/api/orders` | Create an order | Yes |
| GET | `/api/orders` | List current user's orders | Yes |
| GET | `/api/orders/:id` | Get an order | Yes |
| PUT | `/api/orders/:id/cancel` | Cancel an order | Yes |
| GET | `/api/events` | List events | No |
| GET | `/api/events/:id` | Get an event | No |
| POST | `/api/events` | Create an event | Yes |
| POST | `/api/bookings` | Create a booking | Yes |
| GET | `/api/bookings` | List current user's bookings | Yes |
| GET | `/api/bookings/:id` | Get a booking | Yes |

JWT requirements describe the current route middleware, not an administrative permissions system.

### Registration request

Send JSON to `POST /api/auth/register`:

```json
{
  "firstName": "Alex",
  "lastName": "Perera",
  "email": "alex@example.com",
  "phone": "0771234567",
  "password": "example_password"
}
```

Login accepts `email` and `password`. Successful registration and login responses contain `success`, `message`, and a `data` object with `user` and `token`. MongoDB returns the user identifier as `_id`; the Flutter user parser accepts both `_id` and `id`.

Order creation uses item entries containing `productId` and `quantity`. Product and event records must be populated in MongoDB or through their creation endpoints; there is no seed script in `backend/package.json`.

## Development and testing

Run these commands from `frontend/`:

```bash
flutter analyze
flutter test
```

Run the card-form regression tests alone:

```bash
flutter test test/card_expiry_test.dart
```

These tests cover expiry formatting, card-number and CVV limits, and the save-card checkbox. A separate widget test checks the landing screen.

Format Dart code:

```bash
dart format lib test
```

Create release builds from `frontend/`:

```bash
flutter build apk --release
flutter build web
```

Android builds require a configured Android SDK. Platform signing and deployment need their own configuration. The backend currently has no automated test script.

## Current implementation status

- Authentication, product, order, event, and booking API routes are implemented in the backend.
- `AuthService` uses API calls for login and signup. The repository's signup method also calls `/api/auth/register`, while several other repository methods still return mock responses.
- Categories currently use mock data in `ProductService`.
- Payment-method storage in `PaymentService` is in memory. Checkout screens and payment results do not establish a live payment-gateway integration.
- The save-card checkbox records the user's selection and passes it to the payment summary; it does not by itself persist a card or charge it.
- OTP verification, password recovery, and other placeholder flows need their backend integration completed.

## Troubleshooting

| Problem | What to check |
| --- | --- |
| App cannot reach the API | Backend process, port, and `ApiClient.baseUrl`; Android emulator uses `10.0.2.2` rather than `localhost` |
| Physical device cannot connect | Same network, backend computer's LAN IP, and firewall access |
| MongoDB connection fails | `MONGO_URI`, local database availability, or Atlas credentials and network access settings |
| Authentication fails | Request fields, existing account credentials, and consistent `JWT_SECRET` configuration |
| Dart SDK version error | Flutter's bundled Dart SDK must satisfy `^3.10.7` |
| Product or event lists are empty | Add records to the configured database; no seed command is provided |
| Expiry date rejected | Enter a valid month and two-digit year in `MM/YY` format |
| Analysis reports deprecations | Some existing widgets use `withOpacity`; review reported notices separately from compilation errors |

## Contributing

1. Create a branch for your change.
2. Keep frontend changes in `frontend/` and backend changes in `backend/`.
3. Run the relevant checks and tests.
4. Update documentation when setup, endpoints, or behavior changes.
5. Commit your changes and open a pull request with a clear description.

Additional backend documentation is available in [`backend/README.md`](backend/README.md).
