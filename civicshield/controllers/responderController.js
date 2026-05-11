import Responder from '../models/Responder.js';
import User from '../models/User.js';

// Get all responders
export const getResponders = async (req, res) => {
  try {
    const { status, vehicleType } = req.query;
    let query = {};
    if (status) query.status = status;
    if (vehicleType) query.vehicleType = vehicleType;

    const responders = await Responder.find(query)
      .populate('userId', 'name phone avatar badge department vehicleType');

    res.json(responders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get responder by ID
export const getResponder = async (req, res) => {
  try {
    const responder = await Responder.findById(req.params.id)
      .populate('userId', 'name phone avatar badge department');

    if (!responder) {
      return res.status(404).json({ error: 'Responder not found' });
    }

    res.json(responder);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Update responder location
export const updateLocation = async (req, res) => {
  try {
    const { lat, lng, address } = req.body;

    const responder = await Responder.findOneAndUpdate(
      { userId: req.user.id },
      {
        currentLocation: { lat, lng, address, updatedAt: new Date() }
      },
      { new: true }
    ).populate('userId', 'name phone avatar badge');

    if (!responder) {
      return res.status(404).json({ error: 'Responder profile not found' });
    }

    res.json(responder);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Update responder availability
export const updateAvailability = async (req, res) => {
  try {
    const { status } = req.body; // 'available', 'on-duty', 'offline'

    const responder = await Responder.findOneAndUpdate(
      { userId: req.user.id },
      {
        status,
        updatedAt: new Date()
      },
      { new: true }
    ).populate('userId', 'name phone avatar badge');

    if (!responder) {
      return res.status(404).json({ error: 'Responder profile not found' });
    }

    res.json(responder);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get available responders near location
export const getAvailableNear = async (req, res) => {
  try {
    const { lat, lng, radius = 10000, type } = req.query;

    let query = {
      status: 'available',
      'currentLocation.lat': { $exists: true },
      'currentLocation.lng': { $exists: true }
    };

    if (type) query.vehicleType = type;

    const responders = await Responder.find(query)
      .populate('userId', 'name phone avatar vehicleType badge')
      .limit(10);

    // Calculate distance manually (MongoDB geospatial query simplified)
    const nearbyResponders = responders.map(r => ({
      ...r.toObject(),
      distance: calculateDistance(lat, lng, r.currentLocation.lat, r.currentLocation.lng)
    }))
    .filter(r => r.distance <= radius / 1000)
    .sort((a, b) => a.distance - b.distance);

    res.json(nearbyResponders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Calculate distance between two coordinates (Haversine formula)
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

// Initialize responder profile
export const initializeResponder = async (req, res) => {
  try {
    const { vehicleType, department } = req.body;

    let responder = await Responder.findOne({ userId: req.user.id });
    
    if (!responder) {
      responder = new Responder({
        userId: req.user.id,
        vehicleType,
        status: 'offline'
      });
    }

    // Update user with responder info
    await User.findByIdAndUpdate(req.user.id, {
      vehicleType,
      department
    });

    await responder.save();
    await responder.populate('userId', 'name phone avatar badge department');

    res.json(responder);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get responder stats
export const getStats = async (req, res) => {
  try {
    const responder = await Responder.findOne({ userId: req.user.id });

    if (!responder) {
      return res.status(404).json({ error: 'Responder profile not found' });
    }

    res.json({
      totalIncidents: responder.totalIncidentsHandled,
      averageResponseTime: responder.averageResponseTime,
      averageResolutionTime: responder.averageResolutionTime,
      currentAssignments: responder.currentAssignments.length
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
