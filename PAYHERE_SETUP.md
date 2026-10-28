# PayHere product and event payments

Product checkout is implemented for Flutter web, Android and iOS. Buy Now opens an
order summary using current database prices, quantities, profile contact details and
separate delivery address/city/country fields. Pay Now opens PayHere, where the user
selects a payment method. Card details are entered in PayHere.

## Credentials and callback URL

Keep credentials in `backend/.env`:

```dotenv
PAYHERE_MERCHANT_ID=your-merchant-id
PAYHERE_MERCHANT_SECRET=your-registered-mobile-app-secret
PAYHERE_WEB_MERCHANT_SECRET=your-registered-website-domain-secret
PAYHERE_SANDBOX=true
PAYHERE_NOTIFY_URL=https://YOUR-PUBLIC-BACKEND/api/payments/payhere/notify
```

`PAYHERE_NOTIFY_URL` is an application setting we add. It is not a credential supplied
by PayHere. It points to the notification endpoint already implemented in this project.
PayHere must reach this endpoint over the internet to confirm a payment. A browser SDK
success message alone never confirms an order. A localhost URL cannot receive callbacks.

The web-specific secret is optional when the same registered secret covers your web
integration. Register the actual website domain in PayHere Integrations. The native
app currently uses application ID `com.example.chocolate_clicks`; register that app
for native checkout. Use the matching sandbox/live credentials and mode.

Instead of an explicit callback URL, you can set `PUBLIC_API_URL` to your backend's
public HTTPS origin or its `/api` base URL. The backend appends the notification path.
An explicit `PAYHERE_NOTIFY_URL` takes precedence. Never log checkout responses or commit
`.env`; the native SDK requires an app secret while browser checkout receives only a hash.

## Local testing before deployment

1. Start your backend from `backend` with `npm start`. The default port is **5000**;
   a `PORT` setting overrides it.
2. Start an HTTPS tunnel to that port. For example, after installing Cloudflare's
   `cloudflared`, run `cloudflared tunnel --url http://localhost:5000`.
3. Copy the tunnel's HTTPS URL into `PAYHERE_NOTIFY_URL`, followed by
   `/api/payments/payhere/notify`. Restart the backend. Keep the tunnel running.
4. From `frontend`, run
   `flutter run -d chrome --dart-define=API_BASE_URL=https://YOUR-TUNNEL/api`.
   To run on an Android device, omit `-d chrome` and select your device.
5. Run `npm run payhere:check` from `backend` to check configuration without printing
   credential values. Register the frontend website domain with PayHere for browser tests.
6. Complete a sandbox checkout. Profile > Order Details should show **paid** and
   **confirmed** only after the verified callback arrives.

Tunnel URLs may change on restart. Update the callback setting and Flutter API URL when
that happens. A tunnel exposes the local API publicly while running; stop it after testing.
No actual gateway payment has been verified until a sandbox checkout and callback succeed.

## Product catalog and MongoDB

The initial product catalog is copied from the app's existing 25 cakes, brownies and
cookies. Run `npm run seed:products` from `backend` if needed. This inserts missing names
and preserves existing database prices. Checkout resolves older local product identifiers
against this catalog and recalculates the displayed total before payment. The server
rejects stale totals and always uses its saved product prices. Existing product quantity
fields are not used for inventory reservation; inventory management remains separate.

Product payment confirmation works on standalone MongoDB. The paid state is updated
atomically, duplicate payment IDs are rejected, and one uniquely indexed receipt is
upserted. The worker repairs a crash between confirming payment and enqueueing its receipt.

Event payments require MongoDB Atlas or a replica set because seat reservations, booking
confirmation and receipts span multiple documents in a transaction. Standalone MongoDB
cannot process paid event reservations. Event orders retain their reserved seats while
payment is pending, failed or cancelled so late success cannot oversell; abandoned holds
require support reconciliation before releasing seats.

## Saved orders and retries

Each product checkout has a persisted checkout key. Retrying the same request retrieves
the same order; it does not create a duplicate. Order history shows payment and fulfilment
status separately, and supports status refresh and explicit checkout retry after dismissal
or failure. If charged, wait for verification before retrying to avoid another charge.
Already paid orders return no checkout payload. Paid cart quantities are removed only
after verified payment; direct purchases leave the cart unchanged.

The callback verifies signature, merchant, exact amount and currency. Product payments
confirm an order without creating an event booking. Duplicate callbacks do not create
extra receipts; delayed failures cannot undo a successful payment. Refunds and chargebacks
require support reconciliation. Older product orders created before online checkout do
not contain payment snapshots and cannot be retried online.

## Receipts

Keep `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, and `MAIL_FROM` configured.
Verified payments queue a receipt to the email saved from the authenticated profile.
The background worker runs every five seconds. Order Details shows email delivery status
and allows authenticated owners to request a resend. `npm run smtp:verify` checks SMTP;
`npm run smtp:verify -- --send` also sends a test email.

The sent state means the SMTP provider accepted the message, not guaranteed inbox delivery.
Failed sends are not retried automatically because an interrupted SMTP response can be
ambiguous. Reconcile receipts left in sending after a process crash before requeueing them.

## Validation

- `npm test -- --runTestsByPath tests/product-checkout.test.js tests/payhere-signature.test.js tests/smtp.test.js`
  runs controller, signature and SMTP unit tests.
- `npm run test:products:db` exercises product payment APIs against a new temporary database
  on the configured MongoDB server. It uses fake PayHere credentials, sends no emails,
  contacts no gateway, and deletes only its generated test database afterward.
- `npm test` also runs event/booking integration tests using a downloaded MongoDB replica
  set binary; a valid download is required.
- From `frontend`, `flutter test test/order_flow_test.dart test/payment_pages_test.dart`
  checks order parsing, summary layout and payment layouts. `flutter build web` validates
  the browser build.

Official references: [JavaScript SDK](https://support.payhere.lk/api-%26-mobile-sdk/javascript-sdk),
[Flutter SDK](https://support.payhere.lk/api-%26-mobile-sdk/flutter-sdk),
[notification verification](https://support.payhere.lk/api-%26-mobile-sdk/checkout-api).


## Product delivery and charges

Quotes and new product orders use the same server calculation. Tax is 10% of the
merchandise subtotal. Delivery starts at Rs. 300; SERVICE_CHARGE defaults to zero.
DELIVERY_FEE, ORDER_TAX_RATE, SERVICE_CHARGE and DELIVERY_CITY_FEES are configurable
in backend/.env. Restart the backend after changing them. The city table currently
contains temporary Rs. 300?700 area rates requested for local deliveries from No. 8
Stratford Avenue, Colombo 06. These are placeholder rates, not live distance or travel
time calculations. Unknown cities use the base delivery fee. Update the table when
actual delivery zones and rates are finalized. Saved orders retain their original
pricing snapshot; quote changes apply only to new checkouts.


Keep DELIVERY_CITY_FEES as valid JSON with double-quoted city names. Wrap the entire
JSON value in single quotes in .env, for example:

```dotenv
DELIVERY_CITY_FEES='{"Colombo 06":300,"Mount Lavinia":500,"Maharagama":700}'
```

Unquoted city names such as `{Colombo:300}` are invalid JSON. Restart the backend
after editing this value so dotenv reloads the configuration.


## Hosted delivery configuration

Flutter defaults to https://chocolate-clicks-backend.hostless.app/api. Editing your
local backend/.env does not update the hosting dashboard's environment or running
service. Change DELIVERY_CITY_FEES in the hosted backend environment and restart or
redeploy that backend to apply it. Dashboard values should be the JSON object itself,
without an extra pair of shell quotes. A local .env can use single quotes around JSON.

The versioned backend/config/delivery-city-fees.json now contains the existing city
rates. After deploying this code, you can remove the DELIVERY_CITY_FEES override to
use that file. Valid overrides retain priority. The parser also accepts legacy flat
city tables with stripped key quotes and JSON-encoded dashboard strings, without eval
or silently replacing invalid charges.

To explicitly run Flutter against your local backend, use
`flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5000/api`.
This selects the local quote API; real PayHere confirmations still need the public
notification endpoint.
