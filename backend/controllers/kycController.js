exports.uploadKycDocuments = async (req, res) => {
    try {
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ message: 'No files uploaded' });
        }

        // Simulate saving file information to MongoDB
        res.status(200).json({ message: 'KYC documents uploaded successfully' });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

exports.getKycDocuments = async (req, res) => {
    try {
        const user = await KycModel.findOne({ email: req.params.email });
        if (!user) {
            return res.status(404).json({ message: "No KYC documents found" });
        }
        res.status(200).json({ documents: user.documents });
    } catch (error) {
        res.status(500).json({ message: "Server error" });
    }
};