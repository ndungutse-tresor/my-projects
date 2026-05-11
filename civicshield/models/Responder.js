import mongoose from 'mongoose';

const responderSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  currentLocation: {
    lat: Number,
    lng: Number,
    address: String,
    updatedAt: Date
  },
  status: {
    type: String,
    enum: ['available', 'on-duty', 'offline'],
    default: 'offline'
  },
  vehicleType: String,
  vehicleId: String,
  vehicleLocation: {
    lat: Number,
    lng: Number,
    address: String,
    updatedAt: Date
  },
  
  // Capacity
  maxCapacity: { type: Number, default: 1 },
  currentLoad: { type: Number, default: 0 },
  
  // Assignments
  currentAssignments: [{
    incidentId: mongoose.Schema.Types.ObjectId,
    status: String,
    arrivedAt: Date
  }],
  
  // Stats
  totalIncidentsHandled: { type: Number, default: 0 },
  averageResponseTime: { type: Number, default: 0 }, // in minutes
  averageResolutionTime: { type: Number, default: 0 }, // in minutes
  
  // Shift info
  shiftStart: Date,
  shiftEnd: Date,
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

responderSchema.index({ 'currentLocation.lat': 1, 'currentLocation.lng': 1 });

export default mongoose.model('Responder', responderSchema);
