import Incident from '../models/Incident.js';
import Assignment from '../models/Assignment.js';
import Responder from '../models/Responder.js';
import User from '../models/User.js';

// Get platform statistics
export const getStats = async (req, res) => {
  try {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const lastWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);

    // Incidents stats
    const totalIncidents = await Incident.countDocuments();
    const activeIncidents = await Incident.countDocuments({ status: 'active' });
    const todayIncidents = await Incident.countDocuments({ createdAt: { $gte: today } });
    const resolvedIncidents = await Incident.countDocuments({ status: 'resolved' });

    // Responders stats
    const totalResponders = await Responder.countDocuments();
    const availableResponders = await Responder.countDocuments({ status: 'available' });
    const onDutyResponders = await Responder.countDocuments({ status: 'on-duty' });

    // Users stats
    const totalUsers = await User.countDocuments();
    const newUsersToday = await User.countDocuments({ createdAt: { $gte: today } });

    // Assignment stats
    const totalAssignments = await Assignment.countDocuments();
    const completedAssignments = await Assignment.countDocuments({ status: 'completed' });

    // Incident breakdown by type
    const incidentsByType = await Incident.aggregate([
      { $group: { _id: '$type', count: { $sum: 1 } } }
    ]);

    // Average response time
    const avgResponseTime = await Assignment.aggregate([
      { $match: { responseTime: { $exists: true } } },
      { $group: { _id: null, avg: { $avg: '$responseTime' } } }
    ]);

    res.json({
      incidents: {
        total: totalIncidents,
        active: activeIncidents,
        today: todayIncidents,
        resolved: resolvedIncidents,
        byType: incidentsByType
      },
      responders: {
        total: totalResponders,
        available: availableResponders,
        onDuty: onDutyResponders
      },
      users: {
        total: totalUsers,
        newToday: newUsersToday
      },
      assignments: {
        total: totalAssignments,
        completed: completedAssignments
      },
      performance: {
        averageResponseTime: avgResponseTime[0]?.avg || 0
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get live incident feed
export const getLiveIncidents = async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const skip = (page - 1) * limit;

    const incidents = await Incident.find({ status: 'active' })
      .populate('reporter', 'name phone avatar')
      .sort('-createdAt')
      .skip(skip)
      .limit(limit);

    const total = await Incident.countDocuments({ status: 'active' });

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

// Get incident heatmap data
export const getHeatmapData = async (req, res) => {
  try {
    const { days = 30 } = req.query;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const incidents = await Incident.find({
      createdAt: { $gte: startDate }
    }).select('location type severity');

    const heatmapPoints = incidents.map(i => ({
      lat: i.location.lat,
      lng: i.location.lng,
      type: i.type,
      severity: i.severity
    }));

    res.json(heatmapPoints);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get responder locations
export const getResponderLocations = async (req, res) => {
  try {
    const responders = await Responder.find({
      'currentLocation.lat': { $exists: true },
      'currentLocation.lng': { $exists: true }
    })
    .populate('userId', 'name phone avatar badge vehicleType')
    .select('currentLocation userId status vehicleType currentAssignments');

    const locations = responders.map(r => ({
      id: r._id,
      lat: r.currentLocation.lat,
      lng: r.currentLocation.lng,
      name: r.userId?.name,
      status: r.status,
      vehicleType: r.vehicleType,
      currentAssignments: r.currentAssignments.length
    }));

    res.json(locations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get incident trends
export const getIncidentTrends = async (req, res) => {
  try {
    const { days = 30 } = req.query;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const trends = await Incident.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate }
        }
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$createdAt' }
          },
          count: { $sum: 1 },
          resolved: {
            $sum: { $cond: [{ $eq: ['$status', 'resolved'] }, 1, 0] }
          }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    res.json(trends);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
