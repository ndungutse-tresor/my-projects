import express from 'express';
import * as responderController from '../controllers/responderController.js';
import { auth, authorize } from '../middleware/auth.js';
import { validateLocationUpdate } from '../middleware/validation.js';

const router = express.Router();

// Get all responders
router.get('/', auth, responderController.getResponders);

// Get responder by ID
router.get('/:id', auth, responderController.getResponder);

// Initialize responder profile
router.post('/init', auth, authorize(['responder']), responderController.initializeResponder);

// Update responder location
router.put('/location', auth, authorize(['responder']), validateLocationUpdate, responderController.updateLocation);

// Update responder availability
router.put('/status', auth, authorize(['responder']), responderController.updateAvailability);

// Get available responders near location
router.get('/available/near', auth, responderController.getAvailableNear);

// Get responder stats
router.get('/stats', auth, authorize(['responder']), responderController.getStats);

export default router;
