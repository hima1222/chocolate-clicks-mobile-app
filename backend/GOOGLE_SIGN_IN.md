# Google sign-in in Chrome

The Flutter web app uses Google's rendered sign-in button and listens for the
Google authentication event. Calling `GoogleSignIn.authenticate()` from a custom
button is not supported on web with google_sign_in 7.

## Configuration

1. Set `GOOGLE_WEB_CLIENT_ID` in `backend/.env` to the **Web application** OAuth
   client ID. Restart the backend after changing `.env`.
2. In Google Cloud Console, edit that OAuth client and add both
   `http://localhost` and `http://localhost:7357` to **Authorized JavaScript origins**.
   For deployment, add the actual frontend HTTPS origin as well. Origins must
   match the browser URL, including the port, without a path.
3. If the OAuth consent screen is in Testing, add the account being used as a
   test user, unless it already has access through the configured audience.
4. Start the frontend from `frontend` with a fixed port:

   ```powershell
   flutter run -d chrome --web-hostname localhost --web-port 7357
   ```

The frontend fetches the public OAuth client ID from
`GET /api/auth/google/config`, so it follows the backend setting. The existing
`API_BASE_URL` configuration must point to the backend. An optional
`--dart-define=GOOGLE_WEB_CLIENT_ID=...` overrides the fetched client ID and must
match the backend's audience.

Google's returned ID token is sent to `POST /api/auth/google`. The backend
verifies its signature, expiration, audience, and verified-email claim before
creating the app's normal session. Client secrets are never returned to Flutter.
This flow does not need a client secret in the browser.

If the button reports that Google sign-in is unavailable, check that the backend
has restarted and `/api/auth/google/config` returns a successful response. If
Google reports an origin mismatch or access restriction, check the Console
settings above. Completing a real account sign-in is still required to verify
those external settings.

References: [Flutter web plugin](https://pub.dev/packages/google_sign_in_web),
[Google OAuth client setup](https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid).
