# PayHere event payments

This integration uses the native Flutter SDK. Its registered app secret is returned only by authenticated order creation with `Cache-Control: no-store` and is passed to the SDK. It is not stored in orders. This path cannot keep the app secret entirely on the server. Do not log checkout responses or add credentials to source control.

## Sandbox setup

1. Register `com.example.chocolate_clicks` (the current `applicationId` in `frontend/android/app/build.gradle.kts`) in your sandbox PayHere account under Domains & Credentials / Add Domain/App / App. Obtain the Merchant ID and that app's Merchant Secret. Account registration and credentials must be completed by the account owner.
2. Copy the entries from `backend/payhere.env.example` into your existing local `backend/.env`, retaining MONGO_URI, JWT_SECRET and SMTP settings. Keep PAYHERE_SANDBOX=true for sandbox credentials. Never mix sandbox and live credentials or change a merchant secret with unsettled orders outstanding.
3. Use MongoDB Atlas or a MongoDB replica set. Event order creation and payment confirmation require transactions; standalone MongoDB is unsupported. Startup creates the unique order, booking and receipt indexes before accepting requests.
4. Start the backend (`cd backend`, `npm ci`, `npm start`). Its default port is 3000. Expose that port with an HTTPS tunnel and set PAYHERE_NOTIFY_URL to `https://YOUR-TUNNEL/api/payments/payhere/notify`. Restart after changing environment values. PayHere must reach this URL without login or tunnel interstitials.
5. Configure SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS and MAIL_FROM using your mail provider. Without SMTP_HOST, receipts stay queued. A database-backed worker sends queued receipts after the booking transaction commits.
6. From `frontend`, run `flutter pub get`, then `flutter run --dart-define=API_BASE_URL=https://YOUR-TUNNEL/api`. The URL must include `/api`. Native Android/iOS devices cannot use the host computer's localhost. Android requires SDK platform 35 for the published plugin. The project includes the current PayHere Maven repository plus the group-restricted JitPack repository still required by the published Flutter SDK 3.2.3, manifest merge rule, INTERNET permission and release ProGuard rules. iOS additionally requires `pod install` on macOS.
7. For distribution, copy `frontend/android/key.properties.example` to ignored `frontend/android/key.properties` and supply your signing keystore. Release builds use those credentials when present; the existing debug signing fallback remains for sandbox testing. Never distribute a debug-signed build. Register your final application ID before changing it for a release.

Official references: [Flutter SDK](https://support.payhere.lk/api-%26-mobile-sdk/flutter-sdk), [notification verification](https://support.payhere.lk/api-%26-mobile-sdk/checkout-api).

## API and behavior

Authenticated `POST /api/orders` accepts `{ "eventId": "<MongoDB event ID>", "quantity": 2, "billing": { "address": "1 Main Street", "city": "Colombo", "country": "Sri Lanka" } }`. Contact details come from the authenticated user. The backend snapshots the title and price from the database, calculates the amount in cents, reserves seats atomically, and returns `{ success, data: <order>, checkout: <SDK object> }`. A repeated request for the same customer and event returns the saved order and never reserves twice. The quantity is fixed for that order. Paid orders return `checkout: null`.

Orders store `user` (the user ID), `eventId`, `quantity`, the exact two-decimal `amount`, `currency`, `payment_status`, and `payhere_payment_id`. `GET /api/orders/:id` is scoped to the authenticated owner. Existing product order requests remain supported with server-calculated totals.

The public `POST /api/payments/payhere/notify` accepts form-encoded PayHere notifications. It verifies the signature with a constant-time comparison, checks merchant/amount/currency, and only confirms on verified status 2. The transaction saves the paid order, one quantity-aware booking and one uniquely keyed receipt. Duplicate or delayed failure/pending notifications cannot undo payment or enqueue another receipt. Different successful payment IDs for an already-paid order return 409 for reconciliation; payment IDs cannot be reused for a different order.

Paid events cannot bypass checkout through POST /api/bookings. Free events continue to use that endpoint. Paid order/booking cancellation is directed to support because an actual refund must be reconciled before releasing seats. The event button currently books one seat; the service and API also accept larger quantities.

The native SDK callback triggers polling for about 12 seconds. SDK success alone never confirms a booking. Pending orders show Payment processing and can be checked again. Checkout retry is explicit because repeating a charge while a notification is delayed can charge the customer twice. After restarting the app, order creation retrieves the same order and checks its status before permitting an explicit checkout retry.

## Operational limits and reconciliation

- Pending, cancelled and failed event orders retain their seat reservation, allowing retries and late verified success without overselling. There is intentionally no automatic expiration: deleting an unpaid hold while PayHere may still settle could invalidate a paid booking. Before production, implement a reservation expiry/reconciliation job against PayHere's payment records, or have support reconcile abandoned orders and release seats transactionally only after settlement is ruled out. Do not delete pending orders blindly. `bookedCount` therefore includes unpaid reservations.
- Chargebacks and refunds after successful payment require support reconciliation; they do not automatically cancel confirmed attendance. Watch PayHere's merchant dashboard for these events and for extra payments against an already-paid order.
- Receipt claims are atomic across workers and each order has one queue entry. SMTP is not an exactly-once transport: a crash after acceptance can leave a receipt in `sending`. SMTP errors leave `failed`. Review these records against mail provider delivery logs before manually requeueing; they are not retried automatically, avoiding duplicate receipts on ambiguous delivery.
- Keep the API behind HTTPS, protect request/response logs from customer data and credentials, and do a sandbox payment on an Android device before switching PAYHERE_SANDBOX=false with approved live credentials.

## Validation

`cd backend` then `npm test` runs the existing booking tests and PayHere tests using an ephemeral MongoDB replica set (MongoDB binary download may be required). Coverage includes server pricing, validation, seat concurrency, ownership, signature/amount/currency rejection, duplicate callbacks, transaction rollback and receipt deduplication.
