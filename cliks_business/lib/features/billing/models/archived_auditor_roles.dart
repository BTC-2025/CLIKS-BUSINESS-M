/// Archived Auditor Roles Model & Preservation Store
///
/// This file securely preserves auditor role definitions that were removed
/// from the FIN-PRO frontend (for both Mobile OS and macOS), ensuring they are
/// not permanently deleted and can be easily retrieved, inspected, or restored.
///
/// Preserved roles:
/// - Internal Auditor (CIA / CA / CMA)
/// - Cost Auditor (ICMAI CMA)
/// - Secretarial Auditor (ICSI CS)
/// - Forensic Auditor (ICAI FAFD / CFE)
library;

class ArchivedAuditorRole {
  final int id;
  final String fullName;
  final String shortName;
  final String suiteTitle;
  final String suiteBadge;
  final String suiteSubtitle;
  final String coreDeliverableText;
  final List<String> subTabs;
  final Map<String, dynamic>? metadata;

  const ArchivedAuditorRole({
    required this.id,
    required this.fullName,
    required this.shortName,
    required this.suiteTitle,
    required this.suiteBadge,
    required this.suiteSubtitle,
    required this.coreDeliverableText,
    required this.subTabs,
    this.metadata,
  });
}

/// The active roles displayed on the FIN-PRO frontend
const List<String> kActiveAuditorRoles = [
  'Statutory Financial Auditor (ICAI CA)',
  'Tax Auditor (ICAI CA)',
];

/// The short display names for active auditor roles
const List<String> kActiveAuditorRoleShortNames = [
  'Statutory Financial Auditor',
  'Tax Auditor',
];

/// Preserved archived auditor roles removed from frontend
const List<ArchivedAuditorRole> kArchivedAuditorRoles = [
  ArchivedAuditorRole(
    id: 2,
    fullName: 'Internal Auditor (CIA / CA / CMA)',
    shortName: 'Internal Auditor',
    suiteTitle: 'Internal Audit & Controls Suite',
    suiteBadge: 'CIA / CA / CMA STANDARD',
    suiteSubtitle:
        'Operational risk management, IFC (Internal Financial Controls) and COSO framework matrix.',
    coreDeliverableText:
        'Internal Financial Controls (IFC) Report & Risk-Control Matrix (RCM)',
    subTabs: [
      'Risk Control Matrix (RCM)',
      'Entity Level Controls (ELC)',
      'Process Walkthroughs',
      'Testing of Operating Effectiveness',
      'Audit Committee Summary',
    ],
    metadata: {
      'governingBody': 'The Institute of Internal Auditors / ICAI / ICMAI',
      'statutoryAct': 'Companies Act 2013, Section 138',
      'framework': 'COSO Internal Control - Integrated Framework',
    },
  ),
  ArchivedAuditorRole(
    id: 3,
    fullName: 'Cost Auditor (ICMAI CMA)',
    shortName: 'Cost Auditor',
    suiteTitle: 'Cost Audit & Compliance Suite',
    suiteBadge: 'ICMAI CMA STANDARD',
    suiteSubtitle:
        'Statutory cost compliance under Section 148 of Companies Act 2013 and CRA Rules.',
    coreDeliverableText:
        'Form CRA-1 to CRA-4 Cost Audit Report & XBRL Package',
    subTabs: [
      'CRA-1 Cost Records',
      'CRA-2 Form & Filing',
      'CRA-3 Cost Audit Report',
      'CRA-4 Annexures & Reconciliation',
      'Capacity & Ratio Engine',
    ],
    metadata: {
      'governingBody': 'Institute of Cost Accountants of India (ICMAI)',
      'statutoryAct': 'Companies Act 2013, Section 148',
      'filingForms': ['CRA-1', 'CRA-2', 'CRA-3', 'CRA-4'],
    },
  ),
  ArchivedAuditorRole(
    id: 4,
    fullName: 'Secretarial Auditor (ICSI CS)',
    shortName: 'Secretarial Auditor',
    suiteTitle: 'Secretarial Audit & Governance Suite',
    suiteBadge: 'ICSI CS STANDARD',
    suiteSubtitle:
        'Corporate governance audit under Section 204 of the Companies Act 2013 and SEBI LODR Regulations.',
    coreDeliverableText:
        'Form MR-3 Secretarial Audit Report & Annual Secretarial Compliance Report',
    subTabs: [
      'Form MR-3 Compliance',
      'Board & Committee Meetings',
      'MCA Statutory Registers',
      'SEBI LODR Checklists',
      'Secretarial Working Papers',
    ],
    metadata: {
      'governingBody': 'Institute of Company Secretaries of India (ICSI)',
      'statutoryAct': 'Companies Act 2013, Section 204 & SEBI LODR',
      'filingForms': ['MR-3'],
    },
  ),
  ArchivedAuditorRole(
    id: 5,
    fullName: 'Forensic Auditor (ICAI FAFD / CFE)',
    shortName: 'Forensic Auditor',
    suiteTitle: 'Forensic Audit & Fraud Investigation Suite',
    suiteBadge: 'ICAI FAFD / CFE STANDARD',
    suiteSubtitle:
        "Digital forensics, Benford's Law distribution analysis, and fund diversion tracking under IBC & EOW norms.",
    coreDeliverableText:
        'Forensic Audit Investigation Report & Money Trail Evidentiary Pack',
    subTabs: [
      "Benford's Law Fraud Engine",
      'Red Flag Transaction Scanner',
      'Related Party Fund Siphoning',
      'Journal Entry (JE) Testing',
      'Evidentiary Dossier',
    ],
    metadata: {
      'governingBody':
          'ICAI Forensic Accounting and Fraud Detection (FAFD) / ACFE',
      'standards': 'Forensic Accounting and Investigation Standards (FAIS)',
      'regulatoryScope': 'IBC, EOW, CBI, SFIO Norms',
    },
  ),
];

/// Complete historical list of all original 6 auditor roles for safe fallback
const List<String> kAllAuditorRolesArchive = [
  'Statutory Financial Auditor (ICAI CA)',
  'Tax Auditor (ICAI CA)',
  'Internal Auditor (CIA / CA / CMA)',
  'Cost Auditor (ICMAI CMA)',
  'Secretarial Auditor (ICSI CS)',
  'Forensic Auditor (ICAI FAFD / CFE)',
];

/// Helper to lookup an archived role by its historical index
ArchivedAuditorRole? getArchivedAuditorRole(int index) {
  for (final role in kArchivedAuditorRoles) {
    if (role.id == index) return role;
  }
  return null;
}

/// Helper to get the full role display name for any index safely
String getAuditorRoleFullName(int index) {
  if (index >= 0 && index < kActiveAuditorRoles.length) {
    return kActiveAuditorRoles[index];
  }
  final archived = getArchivedAuditorRole(index);
  if (archived != null) return archived.fullName;
  if (index >= 0 && index < kAllAuditorRolesArchive.length) {
    return kAllAuditorRolesArchive[index];
  }
  return kActiveAuditorRoles.first;
}

/// Helper to get the short role name for any index safely
String getAuditorRoleShortName(int index) {
  if (index >= 0 && index < kActiveAuditorRoleShortNames.length) {
    return kActiveAuditorRoleShortNames[index];
  }
  final archived = getArchivedAuditorRole(index);
  if (archived != null) return archived.shortName;
  return kActiveAuditorRoleShortNames.first;
}
