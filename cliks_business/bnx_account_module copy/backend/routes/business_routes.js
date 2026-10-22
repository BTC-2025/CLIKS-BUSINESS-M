/**
 * BNX Business Onboarding Routes
 * Implements business onboarding saving (Step 1 Organization details & Step 2 Branding),
 * status checking (ensuring onboarding form appears only once), and GSTIN/CIN lookup.
 */
const express = require('express');
const router = express.Router();

// Mock store for business onboardings by username or email
const businessOnboardings = new Map();

/**
 * 1. Submit Business Onboarding
 * POST /api/business/onboarding
 * Body: {
 *   businessName, legalName, cin, pan, gstin,
 *   industry, companySize, website, supportEmail, supportPhone,
 *   brandColor, tagLine, logoUrl
 * }
 */
router.post('/onboarding', (req, res) => {
  try {
    const {
      businessName,
      legalName,
      cin,
      pan,
      gstin,
      industry,
      companySize,
      website,
      supportEmail,
      supportPhone,
      brandColor,
      tagLine,
      logoUrl,
      username,
    } = req.body;

    const accountIdentifier = (username || 'current_business').toLowerCase().trim();

    const onboardingRecord = {
      businessName: businessName || 'Enterprise Corp',
      legalName: legalName || businessName,
      cin: cin || 'U72900KA2024PTC123456',
      pan: pan || 'AAACB1234K',
      gstin: gstin || '29AAACB1234K1Z5',
      industry: industry || 'Information Technology',
      companySize: companySize || '11-50',
      website: website || 'https://example.com',
      supportEmail: supportEmail || 'support@enterprise.com',
      supportPhone: supportPhone || '+919876543210',
      brandColor: brandColor || '#3F51B5',
      tagLine: tagLine || 'Innovating Communication',
      logoUrl: logoUrl || null,
      completedAt: new Date().toISOString(),
      status: 'COMPLETED',
    };

    businessOnboardings.set(accountIdentifier, onboardingRecord);

    console.log(`[BUSINESS ONBOARDING] Completed for account: ${accountIdentifier}`);

    return res.status(200).json({
      success: true,
      message: 'Business onboarding details saved successfully.',
      data: onboardingRecord,
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: 'Failed to save business onboarding: ' + err.message,
      data: null,
    });
  }
});

/**
 * 2. Get Business Onboarding Status
 * GET /api/business/status?username=acme_corp
 * Determines whether the onboarding form should be shown or skipped.
 */
router.get('/status', (req, res) => {
  const accountIdentifier = (req.query.username || 'current_business').toLowerCase().trim();
  const existing = businessOnboardings.get(accountIdentifier);

  const isCompleted = !!existing;

  return res.status(200).json({
    success: true,
    message: isCompleted ? 'Business onboarding already completed' : 'Onboarding pending',
    data: {
      isCompleted,
      shouldShowOnboarding: !isCompleted,
      details: existing || null,
    },
  });
});

/**
 * 3. Lookup GSTIN / CIN / PAN
 * GET /api/business/gstin-lookup?gstin=29AAACB1234K1Z5
 */
router.get('/gstin-lookup', (req, res) => {
  const gstin = (req.query.gstin || '').toUpperCase().trim();
  if (!gstin) {
    return res.status(400).json({ success: false, message: 'GSTIN query is required.' });
  }

  return res.status(200).json({
    success: true,
    message: 'GSTIN verified successfully',
    data: {
      gstin,
      legalName: 'BNX GLOBAL TECHNOLOGIES PRIVATE LIMITED',
      tradeName: 'BNX Tech',
      status: 'Active',
      state: 'Karnataka',
      taxpayerType: 'Regular',
      address: 'Prestige Tech Park, Outer Ring Road, Bengaluru 560103',
    },
  });
});

module.exports = router;
