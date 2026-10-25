const fs = require('fs');
const path = require('path');
function resolveImages(data) {
  const manifestPath = path.join(__dirname, '../config/cloudinary-images.json');
  const manifest = fs.existsSync(manifestPath) ? JSON.parse(fs.readFileSync(manifestPath)) : {};
  const resolve = value => manifest[value]?.url || value;
  return { ...data, imageUrl: resolve(data.imageUrl),
    ...(data.cardImage !== undefined ? { cardImage: resolve(data.cardImage) } : {}),
    ...(data.gallery ? { gallery: data.gallery.map(resolve) } : {}) };
}
module.exports = resolveImages;
