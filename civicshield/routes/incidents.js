import express from 'express';
import * as incidentController from '../controllers/incidentController.js';
import { auth, authorize } from '../middleware/auth.js';
import { validateIncident } from '../middleware/validation.js';
import { upload } from '../config/multer.js';

const router = express.Router();

const uploadFields = upload.fields([
  { name: 'audio', maxCount: 1 },
  { name: 'proofFiles', maxCount: 5 }
]);

// Create incident (SOS) — multipart: supports audio + proof images
router.post('/', auth, uploadFields, validateIncident, incidentController.createIncident);

// Get incidents
router.get('/', auth, incidentController.getIncidents);
router.get('/my-incidents', auth, incidentController.getMyIncidents);
router.get('/near/location', auth, incidentController.getIncidentsNear);
router.get('/:id', auth, incidentController.getIncident);

// Update / cancel
router.put('/:id', auth, authorize(['dispatcher', 'admin']), incidentController.updateIncident);
router.post('/:id/cancel', auth, authorize(['dispatcher', 'admin', 'citizen']), incidentController.cancelIncident);

// Cancel within 40-second window (reporter only, no penalty)
router.post('/:id/cancel-mistake', auth, incidentController.cancelAsMistake);

// Flag as false alarm (responder/dispatcher, issues penalty)
router.post('/:id/false-alarm', auth, authorize(['responder', 'dispatcher', 'admin']), incidentController.reportFalseAlarm);

export default router;
