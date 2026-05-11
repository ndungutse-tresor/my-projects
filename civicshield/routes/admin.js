import express from 'express';
import * as adminController from '../controllers/adminController.js';
import { auth, authorize } from '../middleware/auth.js';

const router = express.Router();

// Admin-only routes
router.use(auth, authorize(['admin']));

// User management
router.get('/users', adminController.getAllUsers);
router.put('/users/:id', adminController.updateUser);
router.delete('/users/:id', adminController.deleteUser);

// Incident management
router.get('/incidents', adminController.getAllIncidents);
router.delete('/incidents/:id', adminController.deleteIncident);

// Audit logs
router.get('/logs', adminController.getAuditLogs);

// System health
router.get('/health', adminController.getSystemHealth);

export default router;
