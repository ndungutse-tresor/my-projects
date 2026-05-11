import mongoose from 'mongoose';

const assignmentSchema = new mongoose.Schema({
  incident: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Incident',
    required: true
  },
  responder: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  dispatcher: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  status: {
    type: String,
    enum: ['assigned', 'en-route', 'on-scene', 'completed', 'cancelled'],
    default: 'assigned'
  },
  
  // Timing
  assignedAt: {
    type: Date,
    default: Date.now
  },
  acceptedAt: Date,
  arrivedAt: Date,
  completedAt: Date,
  
  // Notes
  notes: String,
  completionNotes: String,
  
  // Performance metrics
  responseTime: Number, // seconds from assignment to en-route
  travelTime: Number, // seconds from en-route to on-scene
  serviceTime: Number, // seconds from on-scene to completed
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

assignmentSchema.index({ incident: 1, responder: 1 });
assignmentSchema.index({ status: 1 });

export default mongoose.model('Assignment', assignmentSchema);
