import Assignment from '../models/Assignment.js';
import Incident from '../models/Incident.js';
import Responder from '../models/Responder.js';
import AuditLog from '../models/AuditLog.js';

// Create assignment
export const createAssignment = async (req, res) => {
  try {
    const { incidentId, responderId } = req.body;

    // Verify incident exists
    const incident = await Incident.findById(incidentId);
    if (!incident) {
      return res.status(404).json({ error: 'Incident not found' });
    }

    // Create assignment
    const assignment = new Assignment({
      incident: incidentId,
      responder: responderId,
      dispatcher: req.user.id,
      status: 'assigned'
    });

    await assignment.save();
    await assignment.populate('incident responder dispatcher', 'title name email avatar');

    // Log action
    await AuditLog.create({
      user: req.user.id,
      action: 'create_assignment',
      resource: 'Assignment',
      resourceId: assignment._id
    });

    res.status(201).json(assignment);
  } catch (error) {
    console.error('Create assignment error:', error);
    res.status(500).json({ error: error.message });
  }
};

// Get assignments
export const getAssignments = async (req, res) => {
  try {
    const { status, incidentId, responderId } = req.query;
    let query = {};

    if (status) query.status = status;
    if (incidentId) query.incident = incidentId;
    if (responderId) query.responder = responderId;

    const assignments = await Assignment.find(query)
      .populate('incident', 'title type severity location')
      .populate('responder', 'name phone avatar')
      .populate('dispatcher', 'name email')
      .sort('-createdAt');

    res.json(assignments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get assignment by ID
export const getAssignment = async (req, res) => {
  try {
    const assignment = await Assignment.findById(req.params.id)
      .populate('incident')
      .populate('responder', 'name phone avatar')
      .populate('dispatcher', 'name email');

    if (!assignment) {
      return res.status(404).json({ error: 'Assignment not found' });
    }

    res.json(assignment);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Update assignment status
export const updateAssignmentStatus = async (req, res) => {
  try {
    const { status, notes, arrivedAt } = req.body;

    const assignment = await Assignment.findById(req.params.id);
    if (!assignment) {
      return res.status(404).json({ error: 'Assignment not found' });
    }

    assignment.status = status;
    if (notes) assignment.notes = notes;

    // Calculate response time when en-route
    if (status === 'en-route' && !assignment.acceptedAt) {
      assignment.acceptedAt = new Date();
      assignment.responseTime = Math.round((new Date() - assignment.assignedAt) / 1000);
    }

    // Record arrival time when on-scene
    if (status === 'on-scene' && !assignment.arrivedAt) {
      assignment.arrivedAt = arrivedAt || new Date();
      assignment.travelTime = Math.round((assignment.arrivedAt - assignment.acceptedAt) / 1000);
    }

    // Record completion time
    if (status === 'completed' && !assignment.completedAt) {
      assignment.completedAt = new Date();
      assignment.serviceTime = Math.round((assignment.completedAt - assignment.arrivedAt) / 1000);
    }

    await assignment.save();
    await assignment.populate('incident responder dispatcher');

    // Log action
    await AuditLog.create({
      user: req.user.id,
      action: 'update_assignment',
      resource: 'Assignment',
      resourceId: assignment._id,
      changes: { status }
    });

    res.json(assignment);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get assignments for responder
export const getMyAssignments = async (req, res) => {
  try {
    const assignments = await Assignment.find({
      responder: req.user.id,
      status: { $in: ['assigned', 'en-route', 'on-scene'] }
    })
    .populate('incident', 'title type severity location')
    .populate('dispatcher', 'name email')
    .sort('-createdAt');

    res.json(assignments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Assign multiple responders to incident
export const batchAssign = async (req, res) => {
  try {
    const { incidentId, responderIds } = req.body;

    const assignments = [];
    for (const responderId of responderIds) {
      const assignment = new Assignment({
        incident: incidentId,
        responder: responderId,
        dispatcher: req.user.id,
        status: 'assigned'
      });
      await assignment.save();
      assignments.push(assignment);
    }

    await Assignment.populate(assignments, 'incident responder dispatcher');

    res.status(201).json({
      count: assignments.length,
      assignments
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
