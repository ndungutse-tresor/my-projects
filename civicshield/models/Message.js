import mongoose from 'mongoose';

const messageSchema = new mongoose.Schema({
  incident: { type: mongoose.Schema.Types.ObjectId, ref: 'Incident', required: true },
  sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  senderRole: { type: String, enum: ['citizen', 'responder', 'dispatcher', 'admin'] },
  text: { type: String, required: true, maxlength: 1000 },
  readBy: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }]
}, { timestamps: true });

messageSchema.index({ incident: 1, createdAt: 1 });

export default mongoose.model('Message', messageSchema);
