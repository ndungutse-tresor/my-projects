import Incident from '../models/Incident.js';
import Responder from '../models/Responder.js';
import Assignment from '../models/Assignment.js';
import Message from '../models/Message.js';

const socketHandlers = (io, socket) => {
  // New incident broadcast
  socket.on('incident:create', async (data) => {
    try {
      const incident = await Incident.findById(data.incidentId)
        .populate('reporter', 'name phone avatar');
      
      // Broadcast to all connected responders and dispatchers
      io.emit('incident:new', {
        incident,
        timestamp: new Date()
      });

      // Also notify responders nearby based on location
      if (incident.location.lat && incident.location.lng) {
        const nearby = await getRespondersByProximity(
          incident.location.lat,
          incident.location.lng,
          incident.location.radius || 5000
        );
        
        nearby.forEach(responder => {
          io.to(responder.userId.toString()).emit('incident:nearby', {
            incident,
            distance: responder.distance
          });
        });
      }
    } catch (error) {
      console.error('Error broadcasting incident:', error);
    }
  });

  // Responder location update
  socket.on('responder:location', async (data) => {
    try {
      const responder = await Responder.findOneAndUpdate(
        { userId: data.userId },
        {
          currentLocation: {
            lat: data.lat,
            lng: data.lng,
            address: data.address,
            updatedAt: new Date()
          }
        },
        { new: true }
      );

      // Broadcast responder location to dispatchers
      io.emit('responder:location:updated', {
        responderId: responder._id,
        location: responder.currentLocation
      });
    } catch (error) {
      console.error('Error updating responder location:', error);
    }
  });

  // Responder status change
  socket.on('responder:status', async (data) => {
    try {
      const responder = await Responder.findOneAndUpdate(
        { userId: data.userId },
        { status: data.status },
        { new: true }
      );

      io.emit('responder:status:updated', {
        responderId: responder._id,
        status: data.status
      });
    } catch (error) {
      console.error('Error updating responder status:', error);
    }
  });

  // Assignment created
  socket.on('assignment:create', async (data) => {
    try {
      const assignment = await Assignment.findById(data.assignmentId)
        .populate('incident responder dispatcher');

      // Notify the assigned responder
      io.to(assignment.responder._id.toString()).emit('assignment:new', {
        assignment
      });

      // Notify dispatcher
      io.to(assignment.dispatcher._id.toString()).emit('assignment:created', {
        assignment
      });

      // Broadcast to all dashboard viewers
      io.emit('assignment:broadcast', {
        assignment,
        timestamp: new Date()
      });
    } catch (error) {
      console.error('Error broadcasting assignment:', error);
    }
  });

  // Assignment status update
  socket.on('assignment:update', async (data) => {
    try {
      const assignment = await Assignment.findById(data.assignmentId)
        .populate('incident responder dispatcher');

      // Broadcast update to all relevant parties
      io.emit('assignment:status:updated', {
        assignment,
        previousStatus: data.previousStatus,
        newStatus: data.newStatus
      });
    } catch (error) {
      console.error('Error broadcasting assignment update:', error);
    }
  });

  // Incident status update
  socket.on('incident:update', async (data) => {
    try {
      const incident = await Incident.findById(data.incidentId)
        .populate('reporter', 'name phone avatar');

      io.emit('incident:status:updated', {
        incident,
        previousStatus: data.previousStatus,
        newStatus: data.newStatus,
        timestamp: new Date()
      });
    } catch (error) {
      console.error('Error broadcasting incident update:', error);
    }
  });

  // Incident cancellation
  socket.on('incident:cancel', async (data) => {
    try {
      const incident = await Incident.findById(data.incidentId);
      
      io.emit('incident:cancelled', {
        incidentId: incident._id,
        timestamp: new Date()
      });

      // Cancel all related assignments
      await Assignment.updateMany(
        { incident: incident._id, status: { $ne: 'completed' } },
        { status: 'cancelled' }
      );
    } catch (error) {
      console.error('Error cancelling incident:', error);
    }
  });

  // Citizen shares live location (broadcasted to responders in the incident room)
  socket.on('citizen:location:update', ({ incidentId, lat, lng }) => {
    io.to(`incident:${incidentId}`).emit('citizen:location:updated', { incidentId, lat, lng });
  });

  // Responder shares location while on duty (updates DB + broadcasts to dispatcher)
  socket.on('responder:location:duty', async ({ responderId, lat, lng }) => {
    try {
      const responder = await Responder.findOneAndUpdate(
        { userId: responderId },
        { currentLocation: { lat, lng, updatedAt: new Date() } },
        { new: true }
      );
      if (responder) {
        io.emit('responder:location:updated', { responderId: responder._id, location: { lat, lng } });
      }
    } catch {}
  });

  // Real-time chat message
  socket.on('message:send', async (data) => {
    try {
      const { incidentId, text, senderId, senderName, senderRole } = data;
      const message = await Message.create({
        incident: incidentId,
        sender: senderId,
        senderRole,
        text
      });
      await message.populate('sender', 'name role avatar');

      // Broadcast to everyone in this incident's room
      io.to(`incident:${incidentId}`).emit('message:new', { message });
    } catch (error) {
      console.error('Message error:', error);
    }
  });

  // User join room for real-time updates
  socket.on('join:incident', (incidentId) => {
    socket.join(`incident:${incidentId}`);
  });

  socket.on('leave:incident', (incidentId) => {
    socket.leave(`incident:${incidentId}`);
  });

  // User join dispatcher dashboard
  socket.on('join:dashboard', () => {
    socket.join('dashboard');
  });

  socket.on('leave:dashboard', () => {
    socket.leave('dashboard');
  });

  // Disconnect handler
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });

  // Error handler
  socket.on('error', (error) => {
    console.error('Socket error:', error);
  });
};

// Helper function to get responders within proximity
async function getRespondersByProximity(lat, lng, radius) {
  const responders = await Responder.find({
    status: 'available',
    'currentLocation.lat': { $exists: true }
  }).populate('userId');

  return responders
    .map(r => ({
      ...r.toObject(),
      distance: calculateDistance(lat, lng, r.currentLocation.lat, r.currentLocation.lng)
    }))
    .filter(r => r.distance * 1000 <= radius)
    .sort((a, b) => a.distance - b.distance)
    .slice(0, 5); // Top 5 closest
}

function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

export default socketHandlers;
