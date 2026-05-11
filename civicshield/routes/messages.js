import express from 'express';
import { getMessages, sendMessage } from '../controllers/messageController.js';
import { auth } from '../middleware/auth.js';

const router = express.Router();

router.get('/:incidentId', auth, getMessages);
router.post('/:incidentId', auth, sendMessage);

export default router;
