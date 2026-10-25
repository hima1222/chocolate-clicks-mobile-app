const router = require('express').Router();
const multer = require('multer');
const { protect } = require('../middleware/authMiddleware');
const { uploadBuffer } = require('../services/cloudinaryService');
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024, files: 1, fields: 0 },
  fileFilter(req, file, cb) {
    if (!['image/jpeg', 'image/png', 'image/webp', 'image/gif'].includes(file.mimetype)) {
      return cb(Object.assign(new Error('Use a JPEG, PNG, WebP or GIF image'), { statusCode: 400 }));
    }
    cb(null, true);
  },
});
router.post('/', protect, (req, res, next) => {
  upload.single('image')(req, res, async (error) => {
    if (error) return next(Object.assign(error, { statusCode: error.code === 'LIMIT_FILE_SIZE' ? 413 : 400 }));
    if (!req.file) return next(Object.assign(new Error('An image file is required'), { statusCode: 400 }));
    try {
      const result = await uploadBuffer(req.file.buffer);
      res.status(201).json({ success: true, data: { imageUrl: result.secure_url, publicId: result.public_id, width: result.width, height: result.height } });
    } catch (err) {
      next(Object.assign(new Error(err.statusCode === 503 ? err.message : 'Image upload failed. Please try again.'), { statusCode: err.statusCode === 503 ? 503 : 502 }));
    }
  });
});
module.exports = router;
