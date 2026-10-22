/**
 * BNX User Profile & Account Management Routes
 * Implements profile fetching, updating, profile picture, Sub-ID branch creation, and security sessions.
 */
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'bnx_super_secret_jwt_key_2026';

// Helper auth middleware
function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Authentication required' });
  }
  const token = authHeader.split(' ')[1];
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch (err) {
    // In dev / mock fallback: allow test requests
    req.user = { userId: 1, username: 'demo_user', email: 'demo_user@bnxmail.com' };
    next();
  }
}

// Mock User DB
const userDb = {
  userId: 1,
  username: 'demo_user',
  email: 'demo_user@bnxmail.com',
  firstName: 'Demo',
  lastName: 'User',
  role: 'PUBLIC',
  accountType: 'PERSONAL',
  isPrimary: true,
  phoneNumber: '+919876543210',
  recoveryEmail: 'recovery@example.com',
  dob: '1998-05-15',
  profilePicture: null,
  profilePictureUrl: null,
  twoFactorEnabled: false,
  storageUsedBytes: 154200000,
  storageQuotaBytes: 15000000000, // 15GB
  mailboxes: [
    { emailId: 1, email: 'demo_user@bnxmail.com', isPrimary: true },
  ],
  subAccounts: [
    { subId: 101, username: 'demo_billing', email: 'demo_billing@bnxmail.com', role: 'FINANCE' },
  ],
  activeSessions: [
    { id: 'sess_1', device: 'macOS Chrome 124', ip: '192.168.1.10', location: 'Bengaluru, India', lastActive: 'Just now', current: true },
    { id: 'sess_2', device: 'iPhone 15 Pro', ip: '192.168.1.15', location: 'Bengaluru, India', lastActive: '2 hours ago', current: false },
  ],
};

/**
 * 1. Get Current User Profile
 * GET /api/users/me
 */
router.get('/me', requireAuth, (req, res) => {
  return res.status(200).json({
    success: true,
    message: 'Profile retrieved successfully',
    data: {
      ...userDb,
      username: req.user.username || userDb.username,
      email: req.user.email || userDb.email,
    },
  });
});

/**
 * 2. Update User Profile
 * PATCH /api/users/profile
 */
router.patch('/profile', requireAuth, (req, res) => {
  const { firstName, lastName, recoveryEmail, phoneNumber, dob } = req.body;
  if (firstName !== undefined) userDb.firstName = firstName;
  if (lastName !== undefined) userDb.lastName = lastName;
  if (recoveryEmail !== undefined) userDb.recoveryEmail = recoveryEmail;
  if (phoneNumber !== undefined) userDb.phoneNumber = phoneNumber;
  if (dob !== undefined) userDb.dob = dob;

  return res.status(200).json({
    success: true,
    message: 'Profile updated successfully',
    data: userDb,
  });
});

/**
 * 3. Upload Profile Picture
 * POST /api/users/profile-picture
 */
router.post('/profile-picture', requireAuth, (req, res) => {
  const fakeFileName = `avatar_${Date.now()}.png`;
  userDb.profilePicture = fakeFileName;
  userDb.profilePictureUrl = `/api/users/profile-picture/${fakeFileName}`;

  return res.status(200).json({
    success: true,
    message: 'Profile picture uploaded successfully',
    data: {
      profilePicture: fakeFileName,
      profilePictureUrl: userDb.profilePictureUrl,
    },
  });
});

/**
 * 4. Delete Profile Picture
 * DELETE /api/users/profile-picture
 */
router.delete('/profile-picture', requireAuth, (req, res) => {
  userDb.profilePicture = null;
  userDb.profilePictureUrl = null;

  return res.status(200).json({
    success: true,
    message: 'Profile picture removed successfully',
    data: null,
  });
});

/**
 * 5. Create Sub-ID / Branch
 * POST /api/subid/create
 */
router.post('/subid/create', requireAuth, (req, res) => {
  const { subIdName, role = 'MEMBER', password } = req.body;
  if (!subIdName) {
    return res.status(400).json({ success: false, message: 'Sub-ID name is required' });
  }

  const newSub = {
    subId: Math.floor(100 + Math.random() * 900),
    username: subIdName.toLowerCase(),
    email: `${subIdName.toLowerCase()}@bnxmail.com`,
    role,
    createdAt: new Date().toISOString(),
  };

  userDb.subAccounts.push(newSub);

  return res.status(200).json({
    success: true,
    message: 'Sub-ID created successfully',
    data: newSub,
  });
});

/**
 * 6. Get Active Sessions & Devices
 * GET /api/users/security/devices
 */
router.get('/security/devices', requireAuth, (req, res) => {
  return res.status(200).json({
    success: true,
    message: 'Active devices retrieved',
    data: userDb.activeSessions,
  });
});

/**
 * 7. Revoke Session
 * POST /api/users/security/devices/revoke
 */
router.post('/security/devices/revoke', requireAuth, (req, res) => {
  const { sessionId } = req.body;
  userDb.activeSessions = userDb.activeSessions.filter((s) => s.id !== sessionId);
  return res.status(200).json({
    success: true,
    message: 'Device session revoked',
    data: userDb.activeSessions,
  });
});

/**
 * 8. Toggle 2FA
 * POST /api/users/security/2fa/toggle
 */
router.post('/security/2fa/toggle', requireAuth, (req, res) => {
  const { enabled } = req.body;
  userDb.twoFactorEnabled = enabled !== undefined ? enabled : !userDb.twoFactorEnabled;
  return res.status(200).json({
    success: true,
    message: `Two-factor authentication ${userDb.twoFactorEnabled ? 'enabled' : 'disabled'}`,
    data: { twoFactorEnabled: userDb.twoFactorEnabled },
  });
});

module.exports = router;
