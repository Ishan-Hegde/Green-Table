// const express = require('express');
// const multer = require('multer');
// const { uploadKycDocuments, getKycDocuments } = require('../controllers/kycController');

// const router = express.Router();

// // Configure Multer for file uploads
// const storage = multer.memoryStorage();
// const upload = multer({ storage: storage });

// // KYC Document Upload Route
// router.post('/upload', upload.array('kycDocuments', 5), uploadKycDocuments);
// router.get('/documents/:email', getKycDocuments);


// module.exports = router;
const express = require('express');
const router = express.Router();
const multer = require('multer');
const User = require('../models/User');
const KYC = require('../models/KYC');

const upload = multer({ dest: 'uploads/' });

router.post('/upload-kyc', async (req, res, next) => {
    try {
        console.log("Before Multer:", req.body);  // Debugging

        // Multer middleware to handle files
        upload.array('kycDocuments', 5)(req, res, async (err) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }

            console.log("After Multer:", req.body, req.files); // Debugging

            const email = req.body.email;  
            if (!email) {
                return res.status(400).json({ message: 'Email is required' });
            }

            const user = await User.findOne({ email });
            if (!user) {
                return res.status(404).json({ message: 'User not found' });
            }

            // Save document URLs
            const documentUrls = req.files.map(file => `/uploads/${file.filename}`);

            let kyc = await KYC.findOne({ userId: user._id });
            if (kyc) {
                kyc.documents.push(...documentUrls);
                await kyc.save();
            } else {
                kyc = new KYC({
                    userId: user._id,
                    documents: documentUrls,
                    status: 'pending'
                });
                await kyc.save();
            }

            res.status(200).json({ message: 'KYC documents uploaded successfully', documents: documentUrls });
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
