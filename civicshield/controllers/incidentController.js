import Incident from '../models/Incident.js';
import User from '../models/User.js';
import AuditLog from '../models/AuditLog.js';

const PENALTY_BY_TIER = { standard: 5000, private: 15000, vip: 30000 };
const CANCEL_WINDOW_MS = 40 * 1000;

// Create incident (SOS) — supports multipart/form-data with audio + proof files
export const createIncident = async (req, res) => {
  try {
    const { title, description, type, severity, serviceType } = req.body;

    // Location comes as a JSON string from FormData
    let location;
    try {
      location = JSON.parse(req.body.location);
    } catch {
      return res.status(400).json({ error: 'Invalid location format' });
    }

    if (!location.lat || !location.lng) {
      return res.status(400).json({ error: 'Location (lat/lng) is required' });
    }

    const incident = new Incident({
      reporter: req.user.id,
      title,
      description: description || '',
      type,
      severity,
      serviceType: serviceType || 'standard',
      location,
      status: 'active',
      audioFile: req.files?.audio?.[0]?.filename || null,
      proofFiles: (req.files?.proofFiles || []).map(f => f.filename)
    });

    await incident.save();
    await incident.populate('reporter', 'name phone avatar');

    await AuditLog.create({
      user: req.user.id,
      action: 'create',
      resource: 'Incident',
      resourceId: incident._id
    });

    res.status(201).json(incident);
  } catch (error) {
    console.error('Create incident error:', error);
    res.status(500).json({ error: error.message });
  }
};

// Cancel within 40-second window (no penalty — genuine mistake)
export const cancelAsMistake = async (req, res) => {
  try {
    const incident = await Incident.findById(req.params.id);
    if (!incident) return res.status(404).json({ error: 'Incident not found' });

    if (incident.reporter.toString() !== req.user.id) {
      return res.status(403).json({ error: 'Only the reporter can cancel this incident' });
    }

    const age = Date.now() - new Date(incident.createdAt).getTime();
    if (age > CANCEL_WINDOW_MS) {
      return res.status(400).json({
        error: 'Cancel window has closed (40 seconds have passed)',
        secondsElapsed: Math.round(age / 1000)
      });
    }

    incident.status = 'cancelled';
    incident.cancelledAsMistake = true;
    await incident.save();

    await AuditLog.create({
      user: req.user.id,
      action: 'cancel_mistake',
      resource: 'Incident',
      resourceId: incident._id
    });

    res.json({ message: 'Incident cancelled. No penalty applied.', incident });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Flag as false alarm — issued by responder/dispatcher after arriving on scene
export const reportFalseAlarm = async (req, res) => {
  try {
    const incident = await Incident.findById(req.params.id).populate('reporter');
    if (!incident) return res.status(404).json({ error: 'Incident not found' });

    if (incident.falseAlarmReported) {
      return res.status(400).json({ error: 'False alarm already reported for this incident' });
    }

    if (incident.cancelledAsMistake) {
      return res.status(400).json({ error: 'Incident was already cancelled as a mistake' });
    }

    const penalty = PENALTY_BY_TIER[incident.serviceType] || PENALTY_BY_TIER.standard;

    incident.falseAlarmReported = true;
    incident.falseAlarmReportedBy = req.user.id;
    incident.penaltyIssued = true;
    incident.penaltyAmount = penalty;
    incident.status = 'cancelled';
    await incident.save();

    // Add penalty to reporter's balance
    await User.findByIdAndUpdate(incident.reporter._id, {
      $inc: { falseAlarmCount: 1, penaltyBalance: penalty }
    });

    await AuditLog.create({
      user: req.user.id,
      action: 'false_alarm',
      resource: 'Incident',
      resourceId: incident._id,
      changes: { penalty, serviceType: incident.serviceType }
    });

    res.json({
      message: `False alarm confirmed. Reporter fined ${penalty.toLocaleString()} RWF.`,
      incident,
      penaltyAmount: penalty
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get all incidents
export const getIncidents = async (req, res) => {
  try {
    const { status, type, severity, serviceType, page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    const query = {};
    if (status) query.status = status;
    if (type) query.type = type;
    if (severity) query.severity = severity;
    if (serviceType) query.serviceType = serviceType;

    const incidents = await Incident.find(query)
      .populate('reporter', 'name phone avatar')
      .sort({ serviceType: -1, createdAt: -1 }) // VIP first
      .skip(skip)
      .limit(Number(limit));

    const total = await Incident.countDocuments(query);

    res.json({
      incidents,
      pagination: { page: Number(page), limit: Number(limit), total, pages: Math.ceil(total / limit) }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get incident by ID
export const getIncident = async (req, res) => {
  try {
    const incident = await Incident.findById(req.params.id)
      .populate('reporter', 'name phone avatar address')
      .populate('falseAlarmReportedBy', 'name badge');

    if (!incident) return res.status(404).json({ error: 'Incident not found' });
    res.json(incident);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Update incident
export const updateIncident = async (req, res) => {
  try {
    const { status, severity, description } = req.body;
    const incident = await Incident.findByIdAndUpdate(
      req.params.id,
      { status, severity, description },
      { new: true }
    ).populate('reporter', 'name phone avatar');

    if (!incident) return res.status(404).json({ error: 'Incident not found' });

    await AuditLog.create({
      user: req.user.id,
      action: 'update',
      resource: 'Incident',
      resourceId: incident._id,
      changes: { status, severity, description }
    });

    res.json(incident);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Cancel incident
export const cancelIncident = async (req, res) => {
  try {
    const incident = await Incident.findByIdAndUpdate(
      req.params.id,
      { status: 'cancelled' },
      { new: true }
    );

    if (!incident) return res.status(404).json({ error: 'Incident not found' });

    await AuditLog.create({
      user: req.user.id,
      action: 'cancel',
      resource: 'Incident',
      resourceId: incident._id
    });

    res.json(incident);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get incidents near location
export const getIncidentsNear = async (req, res) => {
  try {
    const { lat, lng, radius = 5000 } = req.query;

    const incidents = await Incident.find({ status: 'active' })
      .populate('reporter', 'name phone avatar');

    // Manual Haversine filter (avoids needing 2dsphere index)
    const R = 6371000;
    const nearby = incidents.filter(inc => {
      const dLat = (inc.location.lat - parseFloat(lat)) * Math.PI / 180;
      const dLng = (inc.location.lng - parseFloat(lng)) * Math.PI / 180;
      const a = Math.sin(dLat / 2) ** 2 +
        Math.cos(parseFloat(lat) * Math.PI / 180) *
        Math.cos(inc.location.lat * Math.PI / 180) *
        Math.sin(dLng / 2) ** 2;
      return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)) <= radius;
    });

    res.json(nearby);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get my incidents
export const getMyIncidents = async (req, res) => {
  try {
    const incidents = await Incident.find({ reporter: req.user.id })
      .sort('-createdAt')
      .populate('reporter', 'name phone avatar');

    res.json(incidents);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
