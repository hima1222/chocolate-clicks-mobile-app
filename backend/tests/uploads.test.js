process.env.JWT_SECRET = 'upload-test';
jest.mock('../middleware/authMiddleware', () => ({ protect: (req, res, next) => req.headers.authorization === 'Bearer test' ? next() : res.status(401).json({ message: 'Not authorized' }) }));
jest.mock('../services/cloudinaryService', () => ({ uploadBuffer: jest.fn() }));
const request = require('supertest');
const express = require('express');
const { uploadBuffer } = require('../services/cloudinaryService');
const app = express();
app.use('/api/uploads', require('../routes/uploadRoutes'));
app.use(require('../middleware/errorMiddleware'));
beforeEach(() => jest.clearAllMocks());
test('requires authentication', async () => {
  expect((await request(app).post('/api/uploads')).status).toBe(401);
  expect(uploadBuffer).not.toHaveBeenCalled();
});
test('uploads image bytes and returns the durable URL and ID', async () => {
  uploadBuffer.mockResolvedValue({ secure_url: 'https://res.cloudinary.com/test/image/upload/image.png', public_id: 'uploads/image', width: 10, height: 20 });
  const result = await request(app).post('/api/uploads').set('Authorization', 'Bearer test').attach('image', Buffer.from('image'), { filename: 'image.png', contentType: 'image/png' });
  expect(result.status).toBe(201);
  expect(result.body.data.publicId).toBe('uploads/image');
  expect(result.body.data.imageUrl).toMatch(/^https:/);
  expect(uploadBuffer).toHaveBeenCalledWith(Buffer.from('image'));
});
test('rejects missing files and unsupported types', async () => {
  expect((await request(app).post('/api/uploads').set('Authorization', 'Bearer test')).status).toBe(400);
  const result = await request(app).post('/api/uploads').set('Authorization', 'Bearer test').attach('image', Buffer.from('text'), { filename: 'file.txt', contentType: 'text/plain' });
  expect(result.status).toBe(400);
  expect(uploadBuffer).not.toHaveBeenCalled();
});
test('rejects oversized images', async () => {
  const result = await request(app).post('/api/uploads').set('Authorization', 'Bearer test').attach('image', Buffer.alloc(10 * 1024 * 1024 + 1), { filename: 'large.png', contentType: 'image/png' });
  expect(result.status).toBe(413);
  expect(uploadBuffer).not.toHaveBeenCalled();
});
test('does not expose Cloudinary errors or credentials', async () => {
  uploadBuffer.mockRejectedValue(new Error('secret provider details'));
  const result = await request(app).post('/api/uploads').set('Authorization', 'Bearer test').attach('image', Buffer.from('image'), { filename: 'image.png', contentType: 'image/png' });
  expect(result.status).toBe(502);
  expect(JSON.stringify(result.body)).not.toContain('secret provider details');
});
