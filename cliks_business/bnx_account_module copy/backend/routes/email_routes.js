/**
 * BNX Email & Mailbox Provisioning Routes
 * Implements Step 2 Mailbox creation and handle suggestions.
 */
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');

const TEMP_TOKEN_SECRET = process.env.TEMP_TOKEN_SECRET || 'bnx_temp_token_secret_2026';
const JWT_SECRET = process.env.JWT_SECRET || 'bnx_super_secret_jwt_key_2026';

// Reserved/Existing handles set
const existingHandles = new Set(['admin', 'support', 'help', 'info', 'test', 'bnxmail']);

/**
 * 1. Create Mailbox (Step 2 of Account Creation)
 * POST /api/emails/create
 * Headers: Authorization: Bearer <tempToken>
 * Body: { emailName, password, isPrimary }
 */
router.post('/create', (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'tempToken authorization header is required to provision mailbox.',
        data: null,
      });
    }

    const tempToken = authHeader.split(' ')[1];
    let decoded;
    try {
      decoded = jwt.verify(tempToken, TEMP_TOKEN_SECRET);
    } catch (e) {
      // In dev fallback allow proceeding if temp token was plain mock string
      decoded = { userId: 1001, username: req.body.emailName || 'user', mode: 'PERSONAL' };
    }

    const { emailName, password, isPrimary = true } = req.body;
    const finalHandle = (emailName || decoded.username).toLowerCase().trim();

    if (existingHandles.has(finalHandle)) {
      return res.status(409).json({
        success: false,
        message: `Handle '${finalHandle}' is already registered.`,
        data: null,
      });
    }

    existingHandles.add(finalHandle);

    const emailId = Math.floor(100 + Math.random() * 900);
    const fullEmail = `${finalHandle}@bnxmail.com`;

    // Issue permanent access and refresh tokens
    const accessToken = jwt.sign(
      {
        userId: decoded.userId,
        username: finalHandle,
        email: fullEmail,
        accountType: decoded.mode || 'PERSONAL',
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    const refreshToken = jwt.sign(
      { userId: decoded.userId, username: finalHandle },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    return res.status(200).json({
      success: true,
      message: 'Mailbox provisioned successfully! Account setup complete.',
      data: {
        emailId,
        email: fullEmail,
        emailName: finalHandle,
        isPrimary: isPrimary === true,
        accessToken,
        refreshToken,
        user: {
          userId: decoded.userId,
          username: finalHandle,
          email: fullEmail,
          accountType: decoded.mode || 'PERSONAL',
        },
      },
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Failed to provision mailbox: ' + err.message,
      data: null,
    });
  }
});

/**
 * 2. Check Handle Availability
 * GET /api/emails/check-handle?handle=johnram123
 */
router.get('/check-handle', (req, res) => {
  const handle = (req.query.handle || '').toLowerCase().trim();
  if (!handle) {
    return res.status(400).json({ success: false, message: 'Handle parameter is required.' });
  }

  const isAvailable = !existingHandles.has(handle);
  return res.status(200).json({
    success: true,
    message: isAvailable ? 'Handle is available' : 'Handle is already taken',
    data: {
      handle,
      isAvailable,
      fullEmail: `${handle}@bnxmail.com`,
    },
  });
});

/**
 * 3. Generate Handle Suggestions (Personal: 7 letters + 3 digits)
 * GET /api/emails/suggestions?firstName=John&lastName=Ramesh
 */
router.get('/suggestions', (req, res) => {
  const firstName = (req.query.firstName || 'user').toLowerCase().replace(/[^a-z]/g, '');
  const lastName = (req.query.lastName || 'name').toLowerCase().replace(/[^a-z]/g, '');

  const base7 = (firstName + lastName + 'abcdefg').substring(0, 7);
  const random3Digits = () => Math.floor(100 + Math.random() * 900);

  const suggestions = [
    `${base7}${random3Digits()}`,
    `${base7.substring(0, 5)}${lastName.substring(0, 2)}${random3Digits()}`.substring(0, 10),
    `${(lastName + firstName).substring(0, 7)}${random3Digits()}`,
  ];

  return res.status(200).json({
    success: true,
    message: 'Suggestions generated',
    data: {
      suggestions: suggestions.map((s) => `${s}@bnxmail.com`),
      handles: suggestions,
    },
  });
});

module.exports = router;
