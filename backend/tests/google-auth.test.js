jest.mock('google-auth-library', () => ({
  OAuth2Client: jest.fn().mockImplementation(() => ({ verifyIdToken: jest.fn() })),
}));
jest.mock('../models/User', () => ({ findOne: jest.fn(), create: jest.fn() }));

const { OAuth2Client } = require('google-auth-library');
const User = require('../models/User');
const { googleConfig, googleLogin } = require('../controllers/authController');
const verify = OAuth2Client.mock.results[0].value.verifyIdToken;
const originalEnv = { ...process.env };
const clientId = 'test-web-client.apps.googleusercontent.com';
const response = () => ({ status: jest.fn().mockReturnThis(), json: jest.fn() });

beforeEach(() => {
  jest.clearAllMocks();
  process.env.GOOGLE_WEB_CLIENT_ID = clientId;
  process.env.JWT_SECRET = 'google-auth-test-secret';
});
afterEach(() => { process.env = { ...originalEnv }; });

test('public Google config exposes only the client ID, never env secrets', () => {
  process.env.GOOGLE_CLIENT_SECRET = 'must-not-be-returned';
  const res = response();
  googleConfig({}, res);
  expect(res.json).toHaveBeenCalledWith({ success: true, data: { clientId } });
  expect(JSON.stringify(res.json.mock.calls)).not.toContain('must-not-be-returned');
});

test('missing server client ID disables Google sign-in with a configuration error', async () => {
  delete process.env.GOOGLE_WEB_CLIENT_ID;
  const res = response();
  googleConfig({}, res);
  expect(res.status).toHaveBeenCalledWith(503);
  await googleLogin({ body: { idToken: 'fake-token' } }, res, jest.fn());
  expect(verify).not.toHaveBeenCalled();
});

test('invalid tokens are rejected before any database lookup', async () => {
  verify.mockRejectedValueOnce(new Error('invalid token'));
  const res = response();
  await googleLogin({ body: { idToken: 'fake-token' } }, res, jest.fn());
  expect(verify).toHaveBeenCalledWith({ idToken: 'fake-token', audience: clientId });
  expect(res.status).toHaveBeenCalledWith(401);
  expect(User.findOne).not.toHaveBeenCalled();
});

test('verified Google credentials produce the existing backend session', async () => {
  verify.mockResolvedValueOnce({ getPayload: () => ({
    sub: 'google-user', email: 'USER@example.com', email_verified: true,
  }) });
  User.findOne.mockResolvedValueOnce({ _id: 'user-id', googleId: 'google-user',
    toJSON: () => ({ id: 'user-id', email: 'user@example.com' }) });
  const res = response();
  const next = jest.fn();
  await googleLogin({ body: { idToken: 'fake-token' } }, res, next);
  expect(next).not.toHaveBeenCalled();
  expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true,
    data: { user: { id: 'user-id', email: 'user@example.com' }, token: expect.any(String) } }));
});
