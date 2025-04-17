const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');

const verifyKYCDocument = async ({ documentPath, apiKey, endpoint }) => {
  try {
    const form = new FormData();
    form.append('file', fs.createReadStream(documentPath));
    form.append('api_key', apiKey);

    const response = await axios.post(endpoint, form, {
      headers: form.getHeaders(),
      timeout: 30000
    });

    return {
      status: response.data.verificationStatus,
      details: response.data
    };
  } catch (error) {
    console.error('KYC API Error:', error);
    return { status: 'failed', details: error.message };
  }
};

module.exports = { verifyKYCDocument };