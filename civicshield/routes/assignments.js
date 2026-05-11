import express from 'express';
import * as assignmentController from '../controllers/assignmentController.js';
import { auth, authorize } from '../middleware/auth.js';

const router = express.Router();

// Create assignment (dispatcher/admin)
router.post('/', auth, authorize(['dispatcher', 'admin']), assignmentController.createAssignment);

// Batch assign multiple responders (dispatcher/admin)
router.post('/batch', auth, authorize(['dispatcher', 'admin']), assignmentController.batchAssign);

// Get assignments (filtered by role)
router.get('/', auth, assignmentController.getAssignments);

// Get assignment by ID
router.get('/:id', auth, assignmentController.getAssignment);

// Get my assignments (responder)
router.get('/my/assignments', auth, authorize(['responder']), assignmentController.getMyAssignments);

// Update assignment status
router.put('/:id', auth, assignmentController.updateAssignmentStatus);

export default router;
