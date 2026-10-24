const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
require('dotenv').config({ path: path.join(__dirname, '../.env'), quiet: true });
const { client } = require('../services/cloudinaryService');
const root = path.resolve(__dirname, '../../frontend');
const manifestPath = path.join(__dirname, '../config/cloudinary-images.json');
async function main() {
  const cloud = client();
  const manifest = fs.existsSync(manifestPath) ? JSON.parse(fs.readFileSync(manifestPath)) : {};
  async function walk(dir) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const file = path.join(dir, entry.name);
      if (entry.isDirectory()) { await walk(file); continue; }
      if (!/\.(png|jpe?g|webp|gif)$/i.test(file)) continue;
      const asset = path.relative(root, file).split(path.sep).join('/');
      const hash = crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
      if (manifest[asset]?.hash === hash && manifest[asset]?.cloud === process.env.CLOUDINARY_CLOUD_NAME) continue;
      const result = await cloud.uploader.upload(file, { resource_type: 'image', public_id: `chocolate-clicks/assets/${hash}`, overwrite: false, timeout: 60000 });
      manifest[asset] = { url: result.secure_url, publicId: result.public_id, hash, cloud: process.env.CLOUDINARY_CLOUD_NAME };
      fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
      console.log(`Uploaded ${asset}`);
    }
  }
  await walk(path.join(root, 'assets/images'));
  const urls = Object.fromEntries(Object.entries(manifest).map(([key, value]) => [key, value.url]));
  fs.writeFileSync(path.join(root, 'lib/services/cloudinary_images.dart'), '// Generated public Cloudinary delivery URLs. Local assets are preserved.\nconst cloudinaryImages = <String, String>{\n' + Object.entries(urls).map(([key, value]) => `  ${JSON.stringify(key)}: ${JSON.stringify(value)},`).join('\n') + '\n};\n');
  // Keep seed data local and reusable; resolve URLs at seed time.
  const mongoose = require('mongoose');
  try {
    if (!process.env.MONGO_URI) throw new Error('MONGO_URI is required to migrate database image references');
    await mongoose.connect(process.env.MONGO_URI, { serverSelectionTimeoutMS: 15000 });
    for (const Model of [require('../models/Event'), require('../models/Product')]) {
      for (const doc of await Model.find({})) {
        const updates = {};
        for (const field of ['imageUrl', 'cardImage']) if (urls[doc[field]]) updates[field] = urls[doc[field]];
        if (Array.isArray(doc.gallery) && doc.gallery.some(value => urls[value])) updates.gallery = doc.gallery.map(value => urls[value] || value);
        if (Object.keys(updates).length) await Model.updateOne({ _id: doc._id }, { $set: updates });
      }
    }
    console.log(`Cloudinary ready: ${Object.keys(urls).length} images. Database image references updated. Local files preserved.`);
  } finally { await mongoose.disconnect(); }
}
main().catch(error => { console.error('Image migration failed:', error.message); process.exitCode = 1; });
