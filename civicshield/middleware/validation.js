import { body, validationResult } from 'express-validator';

export const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

export const validateRegister = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
  body('name').trim().notEmpty(),
  body('phone').isMobilePhone(),
  body('role').isIn(['citizen', 'responder', 'dispatcher', 'admin']),
  validate
];

export const validateLogin = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty(),
  validate
];

export const validateIncident = [
  body('title').trim().notEmpty(),
  body('description').optional().trim(),
  body('type').isIn(['medical', 'fire', 'security', 'accident', 'other']),
  body('severity').isIn(['low', 'medium', 'high', 'critical']),
  body('serviceType').optional().isIn(['standard', 'private', 'vip']),
  validate
];

export const validateLocationUpdate = [
  body('lat').isFloat({ min: -90, max: 90 }),
  body('lng').isFloat({ min: -180, max: 180 }),
  validate
];
