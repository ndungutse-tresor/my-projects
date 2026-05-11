import User from '../models/User.js';
import Incident from '../models/Incident.js';
import Responder from '../models/Responder.js';
import AuditLog from '../models/AuditLog.js';

// Create admin user
export const createAdmin = async (req, res) => {
  try {
    const { email, password, name, phone } = req.body;

    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ error: 'User already exists' });
    }

    user = new User({
      email,
      password,
      name,
      phone,
      role: 'admin',
      verified: true
    });

    await user.save();
    res.status(201).json({ message: 'Admin user created', user: user.toJSON() });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get all users
export const getAllUsers = async (req, res) => {
  try {
    const { role, page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    let query = {};
    if (role) query.role = role;

    const users = await User.find(query)
      .select('-password')
      .skip(skip)
      .limit(limit)
      .sort('-createdAt');

    const total = await User.countDocuments(query);

    res.json({
      users,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Update user
export const updateUser = async (req, res) => {
  try {
    const { name, phone, verified, role } = req.body;

    const user = await User.findByIdAndUpdate(
      req.params.id,
      { name, phone, verified, role },
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Delete user
export const deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ message: 'User deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get all incidents (admin view)
export const getAllIncidents = async (req, res) => {
  try {
    const { status, type, page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    let query = {};
    if (status) query.status = status;
    if (type) query.type = type;

    const incidents = await Incident.find(query)
      .populate('reporter', 'name phone email')
      .skip(skip)
      .limit(limit)
      .sort('-createdAt');

    const total = await Incident.countDocuments(query);

    res.json({
      incidents,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Delete incident
export const deleteIncident = async (req, res) => {
  try {
    const incident = await Incident.findByIdAndDelete(req.params.id);

    if (!incident) {
      return res.status(404).json({ error: 'Incident not found' });
    }

    // Log action
    await AuditLog.create({
      user: req.user.id,
      action: 'delete',
      resource: 'Incident',
      resourceId: incident._id
    });

    res.json({ message: 'Incident deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get audit logs
export const getAuditLogs = async (req, res) => {
  try {
    const { action, resource, page = 1, limit = 50 } = req.query;
    const skip = (page - 1) * limit;

    let query = {};
    if (action) query.action = action;
    if (resource) query.resource = resource;

    const logs = await AuditLog.find(query)
      .populate('user', 'name email')
      .skip(skip)
      .limit(limit)
      .sort('-createdAt');

    const total = await AuditLog.countDocuments(query);

    res.json({
      logs,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get system health
export const getSystemHealth = async (req, res) => {
  try {
    const usersCount = await User.countDocuments();
    const incidentsCount = await Incident.countDocuments();
    const respondersCount = await Responder.countDocuments();
    const activeIncidents = await Incident.countDocuments({ status: 'active' });
    const availableResponders = await Responder.countDocuments({ status: 'available' });

    res.json({
      status: 'healthy',
      timestamp: new Date(),
      database: 'connected',
      metrics: {
        totalUsers: usersCount,
        totalIncidents: incidentsCount,
        activeIncidents,
        totalResponders: respondersCount,
        availableResponders
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};
