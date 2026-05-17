const express = require('express');
const multer  = require('multer');
const auth    = require('../middleware/auth');
const Photo   = require('../models/Photo');

const router = express.Router();

// Store file in memory (no disk needed)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (req, file, cb) => {
    // Android's image_picker sometimes labels images as application/octet-stream
    // — accept it if the file extension looks like an image.
    const mt = file.mimetype || '';
    const name = (file.originalname || '').toLowerCase();
    const okMime = /^image\//.test(mt);
    const okOctet = mt === 'application/octet-stream'
      && /\.(jpe?g|png|webp|heic|heif|gif|bmp)$/.test(name);
    const ok = okMime || okOctet;
    cb(ok ? null : new Error(`Not an image: ${mt}`), ok);
  },
});

// POST /api/uploads/photo — save image to MongoDB, return URL
router.post('/photo', auth, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No file received' });

    // Normalize generic octet-stream to image/jpeg (or by extension) so the
    // browser/CachedNetworkImage receives a proper Content-Type when serving.
    let contentType = req.file.mimetype;
    if (contentType === 'application/octet-stream') {
      const name = (req.file.originalname || '').toLowerCase();
      if      (name.endsWith('.png'))  contentType = 'image/png';
      else if (name.endsWith('.webp')) contentType = 'image/webp';
      else if (name.endsWith('.gif'))  contentType = 'image/gif';
      else if (name.endsWith('.heic') || name.endsWith('.heif')) contentType = 'image/heic';
      else contentType = 'image/jpeg';
    }
    const photo = await Photo.create({
      data:        req.file.buffer,
      contentType,
      uploadedBy:  req.user.id,
    });

    const url = `${req.protocol}://${req.get('host')}/api/uploads/photo/${photo._id}`;
    res.status(201).json({ url });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/uploads/photo/:id — serve image from MongoDB
router.get('/photo/:id', async (req, res) => {
  try {
    const photo = await Photo.findById(req.params.id);
    if (!photo) return res.status(404).json({ error: 'Not found' });
    res.set('Content-Type', photo.contentType);
    res.set('Cache-Control', 'public, max-age=31536000');
    res.send(photo.data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;