import mongoose from 'mongoose';
import bcryptjs from 'bcryptjs';

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  phone: {
    type: String,
    required: true
  },
  role: {
    type: String,
    enum: ['citizen', 'responder', 'dispatcher', 'admin'],
    default: 'citizen'
  },
  verified: {
    type: Boolean,
    default: false
  },
  avatar: String,
  address: String,
  badge: String, // For responders and dispatchers
  department: String, // For responders and dispatchers
  
  // Responder specific fields
  availability: {
    type: String,
    enum: ['available', 'on-duty', 'offline'],
    default: 'offline'
  },
  vehicleType: String,
  responderType: {
    type: String,
    enum: ['ambulance', 'police', 'fire', 'rescue'],
  },

  // Service tier
  serviceType: {
    type: String,
    enum: ['standard', 'private', 'vip'],
    default: 'standard'
  },

  // False alarm tracking
  falseAlarmCount: { type: Number, default: 0 },
  penaltyBalance: { type: Number, default: 0 }, // amount owed in RWF

  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  const salt = await bcryptjs.genSalt(10);
  this.password = await bcryptjs.hash(this.password, salt);
  next();
});

// Method to compare passwords
userSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcryptjs.compare(enteredPassword, this.password);
};

// Remove password from response
userSchema.methods.toJSON = function() {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};

export default mongoose.model('User', userSchema);
