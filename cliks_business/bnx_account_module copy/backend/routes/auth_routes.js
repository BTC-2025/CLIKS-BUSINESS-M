/**
 * BNX Auth & OTP Routes
 * Implements endpoints for Account Registration, Login, Mobile OTP, Parent OTP, and Token Refresh.
 */
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'bnx_super_secret_jwt_key_2026';
const TEMP_TOKEN_SECRET = process.env.TEMP_TOKEN_SECRET || 'bnx_temp_token_secret_2026';

// In-memory mock stores for OTP and sessions
const activeOtps = new Map(); // phone -> { code, expiresAt, verified }
const usersStore = new Map(); // username -> userData

/**
 * 1. Register Account (Step 1)
 * POST /api/auth/register
 * Body: { username, password, firstName, lastName, phoneNumber, dob, mode, gender, ... }
 */
router.post('/register', (req, res) => {
  try {
    const {
      username,
      password,
      firstName,
      lastName,
      phoneNumber,
      dob,
      gender,
      mode = 'PERSONAL', // PERSONAL | BUSINESS | CHILD
      businessName,
      companyCin,
      companyPan,
      parentPhoneNumber,
    } = req.body;

    if (!username || !password || !firstName) {
      return res.status(400).json({
        success: false,
        message: 'Username, password, and first name are required.',
        data: null,
      });
    }

    const normalizedUsername = username.toLowerCase().trim();

    if (usersStore.has(normalizedUsername)) {
      return res.status(409).json({
        success: false,
        message: 'Username or handle already exists. Please pick another one.',
        data: null,
      });
    }

    const userId = Math.floor(1000 + Math.random() * 9000);
    const tempToken = jwt.sign(
      {
        userId,
        username: normalizedUsername,
        mode,
        step: 'AWAITING_MAILBOX_PROVISION',
      },
      TEMP_TOKEN_SECRET,
      { expiresIn: '2h' }
    );

    const newUser = {
      userId,
      username: normalizedUsername,
      firstName,
      lastName: lastName || '',
      phoneNumber: phoneNumber || '',
      dob: dob || '',
      gender: gender || '',
      mode: mode.toUpperCase(),
      businessName: businessName || null,
      companyCin: companyCin || null,
      companyPan: companyPan || null,
      parentPhoneNumber: parentPhoneNumber || null,
      registeredAt: new Date().toISOString(),
      mailboxCreated: false,
      businessOnboardingCompleted: false,
    };

    usersStore.set(normalizedUsername, newUser);

    return res.status(200).json({
      success: true,
      message: 'User registered successfully. Proceed to mailbox creation with tempToken.',
      data: {
        userId,
        username: normalizedUsername,
        accountType: mode.toUpperCase() === 'PERSONAL' ? 'PUBLIC' : mode.toUpperCase(),
        tempToken,
      },
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Internal server error: ' + err.message,
      data: null,
    });
  }
});

/**
 * 2. Send Mobile OTP (Registration & Verification)
 * POST /api/auth/send-mobile-otp
 * Body: { phoneNumber, countryCode, type }
 */
router.post('/send-mobile-otp', (req, res) => {
  try {
    const { phoneNumber, countryCode = '+91', type = 'registration' } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required.',
        data: null,
      });
    }

    const fullPhone = `${countryCode}${phoneNumber}`.replace(/\s+/g, '');
    // Standard mock OTP code: 123456 (or generated 6-digit in dev)
    const otpCode = '123456';
    const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes

    activeOtps.set(fullPhone, { code: otpCode, expiresAt, verified: false });

    console.log(`[OTP SERVICE] Sent OTP ${otpCode} to ${fullPhone} for ${type}`);

    return res.status(200).json({
      success: true,
      message: `OTP sent successfully to ${fullPhone}. Valid for 5 minutes.`,
      data: {
        phoneNumber: fullPhone,
        cooldownSeconds: 60,
        expiresInSeconds: 300,
        // In local test/dev mode we echo the code for rapid testing
        devOtp: otpCode,
      },
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Failed to send OTP: ' + err.message,
      data: null,
    });
  }
});

/**
 * 3. Verify Mobile OTP
 * POST /api/auth/verify-mobile-otp
 * Body: { phoneNumber, countryCode, otp }
 */
router.post('/verify-mobile-otp', (req, res) => {
  try {
    const { phoneNumber, countryCode = '+91', otp } = req.body;

    if (!phoneNumber || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and 6-digit OTP code are required.',
        data: null,
      });
    }

    const fullPhone = `${countryCode}${phoneNumber}`.replace(/\s+/g, '');
    const entry = activeOtps.get(fullPhone);

    // Accept master test OTP '123456' or stored code
    if ((entry && entry.code === otp.trim()) || otp.trim() === '123456') {
      if (entry && Date.now() > entry.expiresAt) {
        return res.status(400).json({
          success: false,
          message: 'OTP has expired. Please request a new one.',
          data: null,
        });
      }

      if (entry) {
        entry.verified = true;
      }

      return res.status(200).json({
        success: true,
        message: 'Phone number verified successfully.',
        data: {
          verified: true,
          phoneNumber: fullPhone,
          verificationToken: jwt.sign({ fullPhone, verified: true }, JWT_SECRET, { expiresIn: '1h' }),
        },
      });
    }

    return res.status(400).json({
      success: false,
      message: 'Invalid OTP code. Please enter the correct 6-digit code.',
      data: null,
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'OTP verification failed: ' + err.message,
      data: null,
    });
  }
});

/**
 * 4. Child Account: Send Parent Consent OTP
 * POST /api/auth/child/send-parent-otp
 * Body: { parentPhoneNumber, parentEmail, childFirstName }
 */
router.post('/child/send-parent-otp', (req, res) => {
  try {
    const { parentPhoneNumber, parentEmail, childFirstName } = req.body;
    const target = parentPhoneNumber || parentEmail;

    if (!target) {
      return res.status(400).json({
        success: false,
        message: 'Parent phone number or email is required for child account consent.',
        data: null,
      });
    }

    const otpCode = '123456';
    activeOtps.set(target, { code: otpCode, expiresAt: Date.now() + 5 * 60 * 1000, verified: false });

    return res.status(200).json({
      success: true,
      message: `Parent consent OTP sent to ${target}.`,
      data: {
        target,
        devOtp: otpCode,
      },
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message, data: null });
  }
});

/**
 * 5. Child Account: Verify Parent Consent OTP
 * POST /api/auth/child/verify-parent-otp
 * Body: { parentTarget, otp }
 */
router.post('/child/verify-parent-otp', (req, res) => {
  try {
    const { parentTarget, otp } = req.body;
    if (!parentTarget || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Target and OTP are required.',
        data: null,
      });
    }

    if (otp.trim() === '123456') {
      return res.status(200).json({
        success: true,
        message: 'Parent consent verified successfully.',
        data: { verified: true, parentConsentToken: 'parent_consent_approved' },
      });
    }

    return res.status(400).json({ success: false, message: 'Invalid parent verification code.' });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

/**
 * 6. User Login
 * POST /api/auth/login
 * Body: { username, password }
 */
router.post('/login', (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username and password are required.',
        data: null,
      });
    }

    const normalized = username.toLowerCase().trim().replace('@bnxmail.com', '');
    let user = usersStore.get(normalized);

    // Fallback default test user if not registered yet
    if (!user) {
      user = {
        userId: 1,
        username: normalized,
        email: `${normalized}@bnxmail.com`,
        firstName: normalized.charAt(0).toUpperCase() + normalized.slice(1),
        lastName: 'User',
        accountType: 'PERSONAL',
        mode: 'PERSONAL',
        businessOnboardingCompleted: false,
      };
      usersStore.set(normalized, user);
    }

    const accessToken = jwt.sign(
      {
        userId: user.userId,
        username: user.username,
        email: `${user.username}@bnxmail.com`,
        accountType: user.accountType || user.mode || 'PERSONAL',
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    const refreshToken = jwt.sign(
      { userId: user.userId, username: user.username },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        accessToken,
        refreshToken,
        expiresIn: 86400,
        user: {
          userId: user.userId,
          username: user.username,
          email: `${user.username}@bnxmail.com`,
          firstName: user.firstName,
          lastName: user.lastName,
          accountType: user.accountType || user.mode || 'PERSONAL',
          profilePicture: user.profilePicture || null,
          businessOnboardingCompleted: user.businessOnboardingCompleted || false,
        },
      },
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Login failed: ' + err.message,
      data: null,
    });
  }
});

/**
 * 7. Refresh Token
 * POST /api/auth/refresh
 */
router.post('/refresh', (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(400).json({ success: false, message: 'Refresh token required.' });
  }

  try {
    const decoded = jwt.verify(refreshToken, JWT_SECRET);
    const newAccessToken = jwt.sign(
      { userId: decoded.userId, username: decoded.username },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    return res.status(200).json({
      success: true,
      message: 'Token refreshed',
      data: { accessToken: newAccessToken, expiresIn: 86400 },
    });
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid refresh token.' });
  }
});

module.exports = { router, usersStore };
