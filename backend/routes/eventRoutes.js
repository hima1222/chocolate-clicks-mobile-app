const express = require('express');
const { getEvents, getEventById, createEvent } = require('../controllers/eventController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', getEvents);
router.get('/:id', getEventById);
router.post('/', protect, createEvent);

module.exports = router;
