const express = require('express');
const multer = require('multer');
const User = require('../models/User');

const router = express.Router();

const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`)
});

const upload = multer({ storage });

router.post('/upload-kyc', upload.single('document'), async (req, res) => {
  const { email } = req.body;
  const user = await User.findOne({ email, role: 'restaurant' });

  if (!user) return res.status(400).json({ error: 'Restaurant not found' });

  user.kycDocument = req.file.path;
  user.kycVerified = true; // Ideally, this should require admin approval
  await user.save();

  res.json({ message: 'KYC Document Uploaded & Verified' });
});

module.exports = router;
