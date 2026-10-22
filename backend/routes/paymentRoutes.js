const express = require('express');
const { notify } = require('../controllers/payhereController');
const router = express.Router();
router.post('/payhere/notify', express.urlencoded({ extended: false, limit: '16kb' }), notify);
module.exports = router;
