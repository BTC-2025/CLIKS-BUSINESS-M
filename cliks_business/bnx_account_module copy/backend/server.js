/**
 * BNX Mail - Complete Account & Auth Backend Server
 * Standalone mock and production-ready Express server implementing all Account APIs:
 * - Registration (Step 1)
 * - Mailbox Provisioning (Step 2)
 * - Mobile OTP & Parent OTP Verification
 * - Login & Token Refresh
 * - Profile & Sub-ID Management
 * - Business Onboarding & Status
 */

const express = require('express');
const cors = require('cors');

const { router: authRouter } = require('./routes/auth_routes');
const emailRouter = require('./routes/email_routes');
const userRouter = require('./routes/user_routes');
const businessRouter = require('./routes/business_routes');

const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request Logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    service: 'BNX Mail Account Service',
    timestamp: new Date().toISOString(),
    endpoints: [
      'POST /api/auth/register',
      'POST /api/auth/send-mobile-otp',
      'POST /api/auth/verify-mobile-otp',
      'POST /api/auth/child/send-parent-otp',
      'POST /api/auth/child/verify-parent-otp',
      'POST /api/auth/login',
      'POST /api/auth/refresh',
      'POST /api/emails/create',
      'GET  /api/emails/check-handle',
      'GET  /api/emails/suggestions',
      'GET  /api/users/me',
      'PATCH /api/users/profile',
      'POST /api/users/profile-picture',
      'DELETE /api/users/profile-picture',
      'POST /api/subid/create',
      'GET  /api/users/security/devices',
      'POST /api/business/onboarding',
      'GET  /api/business/status',
      'GET  /api/business/gstin-lookup',
    ],
  });
});

// Mount Routes
app.use('/api/auth', authRouter);
app.use('/api/emails', emailRouter);
app.use('/api/users', userRouter);
app.use('/api/business', businessRouter);
// Direct alias for subid create as specified in documentation
app.use('/api/subid', userRouter);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Endpoint ${req.method} ${req.originalUrl} not found on BNX Account Service.`,
    data: null,
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('[SERVER ERROR]', err);
  res.status(500).json({
    success: false,
    message: err.message || 'Internal server error occurred.',
    data: null,
  });
});

// Start Server if executed directly
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`====================================================`);
    console.log(`🚀 BNX Mail Account & Auth Backend running on port ${PORT}`);
    console.log(`📍 Base URL: http://localhost:${PORT}/api`);
    console.log(`🩺 Health check: http://localhost:${PORT}/health`);
    console.log(`🔑 Master Dev OTP for testing: 123456`);
    console.log(`====================================================`);
  });
}

module.exports = app;
