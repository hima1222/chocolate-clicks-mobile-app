const cloudinary = require('cloudinary').v2;
function client() {
  const { CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET } = process.env;
  if (!CLOUDINARY_CLOUD_NAME || !CLOUDINARY_API_KEY || !CLOUDINARY_API_SECRET) {
    const error = new Error('Cloudinary credentials are not configured on the server');
    error.statusCode = 503;
    throw error;
  }
  cloudinary.config({ cloud_name: CLOUDINARY_CLOUD_NAME, api_key: CLOUDINARY_API_KEY, api_secret: CLOUDINARY_API_SECRET, secure: true });
  return cloudinary;
}
function uploadBuffer(buffer) {
  return new Promise((resolve, reject) => {
    client().uploader.upload_stream({ resource_type: 'image', folder: 'chocolate-clicks/uploads', allowed_formats: ['jpg', 'png', 'webp', 'gif'], timeout: 60000 },
      (error, result) => error ? reject(error) : resolve(result)).end(buffer);
  });
}
module.exports = { client, uploadBuffer };
