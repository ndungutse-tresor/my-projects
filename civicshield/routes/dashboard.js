import express from 'express';
import * as dashboardController from '../controllers/dashboardController.js';
import { auth, authorize } from '../middleware/auth.js';

const router = express.Router();

// Get platform statistics (dispatcher/admin)
router.get('/stats', auth, authorize(['dispatcher', 'admin']), dashboardController.getStats);

// Get live incident feed
router.get('/incidents/live', auth, authorize(['dispatcher', 'admin']), dashboardController.getLiveIncidents);

// Get heatmap data
router.get('/heatmap', auth, authorize(['dispatcher', 'admin']), dashboardController.getHeatmapData);

// Get responder locations
router.get('/responders/locations', auth, authorize(['dispatcher', 'admin']), dashboardController.getResponderLocations);

// Get incident trends
router.get('/trends', auth, authorize(['dispatcher', 'admin']), dashboardController.getIncidentTrends);

export default router;
