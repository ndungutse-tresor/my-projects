import Message from '../models/Message.js';
import Incident from '../models/Incident.js';

export const getMessages = async (req, res) => {
  try {
    const messages = await Message.find({ incident: req.params.incidentId })
      .populate('sender', 'name role avatar')
      .sort('createdAt');
    res.json(messages);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const sendMessage = async (req, res) => {
  try {
    const { incidentId } = req.params;
    const { text } = req.body;

    if (!text?.trim()) return res.status(400).json({ error: 'Message text is required' });

    const incident = await Incident.findById(incidentId);
    if (!incident) return res.status(404).json({ error: 'Incident not found' });

    const message = await Message.create({
      incident: incidentId,
      sender: req.user.id,
      senderRole: req.user.role,
      text: text.trim()
    });
    await message.populate('sender', 'name role avatar');

    res.status(201).json(message);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
