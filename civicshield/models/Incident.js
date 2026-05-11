import mongoose from 'mongoose';

const incidentSchema = new mongoose.Schema({
  reporter: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ''
  },
  type: {
    type: String,
    enum: ['medical', 'fire', 'security', 'accident', 'other'],
    required: true
  },
  severity: {
    type: String,
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'medium'
  },
  location: {
    lat: {
      type: Number,
      required: true
    },
    lng: {
      type: Number,
      required: true
    },
    address: String,
    radius: { type: Number, default: 500 } // meters for responder search
  },
  status: {
    type: String,
    enum: ['active', 'in-progress', 'resolved', 'cancelled'],
    default: 'active'
  },
  assignedResponders: [{
    responderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Responder'
    },
    status: {
      type: String,
      enum: ['assigned', 'en-route', 'on-scene', 'completed'],
      default: 'assigned'
    },
    arrivedAt: Date,
    completedAt: Date
  }],
  
  // Service tier
  serviceType: {
    type: String,
    enum: ['standard', 'private', 'vip'],
    default: 'standard'
  },

  // Evidence & media
  audioFile: String,
  proofFiles: [String],

  // Cancellation & penalty tracking
  cancelledAsMistake: { type: Boolean, default: false },
  falseAlarmReported: { type: Boolean, default: false },
  falseAlarmReportedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  penaltyIssued: { type: Boolean, default: false },
  penaltyAmount: { type: Number, default: 0 },

  // For tracking
  reportedAt: {
    type: Date,
    default: Date.now
  },
  startedAt: Date,
  resolvedAt: Date,
  
  // Additional details
  urgency: {
    type: String,
    enum: ['routine', 'priority', 'emergency'],
    default: 'emergency'
  },
  estimatedVictims: Number,
  injuries: String,
  hazards: String,
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

// Index for geospatial queries
incidentSchema.index({ 'location.lat': 1, 'location.lng': 1 });

export default mongoose.model('Incident', incidentSchema);
