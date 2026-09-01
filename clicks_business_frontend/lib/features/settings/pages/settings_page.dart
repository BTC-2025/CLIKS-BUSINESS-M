import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/settings_form_widgets.dart';
import '../../../widgets/app_ui_kit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Print Tab State
  String _printerType = 'REGULAR';
  bool _repeatHeader = true;
  final TextEditingController _displayTitleController = TextEditingController(text: 'My Super Company');
  String _pageDim = 'A4 Size';

  // Taxes & GST State
  bool _enableGstMode = true;
  bool _forceHsnMandatory = true;
  bool _applyReverseCharge = false;
  bool _showPlaceOfSupply = true;

  // Contacts State
  bool _contactGroupClustering = false;
  bool _loyaltyContribution = true;
  bool _activeStatusBadging = false;
  bool _autoReminders = true;

  // Accounting State
  bool _enableAccountingModule = false;

  // Payment State
  bool _instantUpiQr = true;
  bool _cardPaymentSettlements = false;
  bool _automatedReminders = true;

  // FIN-PRO State
  bool _multiCurrencyLedgers = false;
  bool _aiCashflowProjections = true;
  bool _smartAuditGstSync = false;

  // Transaction Tab State
  bool _invoiceBillNo = true;
  bool _addTimeOnTransactions = false;
  bool _cashSaleByDefault = false;
  bool _billingNameOfContacts = false;
  bool _customersPoDetails = false;

  // Items Table State
  bool _inclusiveTaxOnRate = true;
  bool _displayPurchasePrice = true;
  bool _showLast5SalePrice = false;
  bool _showLast5PurchasePrice = false;
  bool _freeItemQty = false;
  bool _count = false;

  // Taxes, Discount & Totals State
  bool _transactionWiseTax = false;
  bool _transactionWiseDiscount = false;
  bool _roundOffTotal = true;

  // More Transaction Features State
  bool _ewayBillNo = false;
  bool _quickEntry = false;
  bool _doNotShowPreview = false;
  bool _passcodeForEditDelete = false;
  bool _discountDuringPayments = false;
  bool _linkPaymentsToInvoices = false;
  bool _dueDatesTerms = false;
  bool _showProfitOnSale = false;

  // Transaction Prefixes Controllers
  final TextEditingController _salePrefixController = TextEditingController(text: 'INV-');
  final TextEditingController _creditNotePrefixController = TextEditingController(text: 'CN-');
  final TextEditingController _saleOrderPrefixController = TextEditingController(text: 'SO-');
  final TextEditingController _purchaseOrderPrefixController = TextEditingController(text: 'PO-');
  final TextEditingController _estimatePrefixController = TextEditingController(text: 'EST-');
  final TextEditingController _proformaPrefixController = TextEditingController(text: 'PRO-');
  final TextEditingController _deliveryChallanPrefixController = TextEditingController(text: 'DC-');
  final TextEditingController _paymentInPrefixController = TextEditingController(text: 'PAY-');

  // Billing Type
  String _billingType = 'Full';

  // General Tab State
  bool _securityPasscode = false;
  bool _preventNegativeInventory = false;
  bool _lockContactGeneration = false;
  bool _godownLinks = false;
  bool _autoBackup = true;
  bool _auditTrail = true;
  bool _activateDeliveryChallans = true;
  bool _reverseGoodsLogic = true;
  bool _displayAmount = false;
  bool _darkMode = false;
  String _language = 'English (US)';
  bool _pushNotifications = true;
  bool _emailDigest = false;
  bool _publicProfile = true;
  bool _twoFactorAuth = true;
  bool _dataAnalytics = false;

  // Org Profile State
  final TextEditingController _businessNameController = TextEditingController(text: 'Cliks Business');
  final TextEditingController _phoneNumberController = TextEditingController(text: '9876543210');
  final TextEditingController _gstinController = TextEditingController(text: '27AAAAA0000A1Z5');
  final TextEditingController _emailController = TextEditingController(text: 'contact@cliks.business');
  final TextEditingController _booksDateController = TextEditingController(text: '01-04-2026');
  final TextEditingController _pincodeController = TextEditingController(text: '400001');
  final TextEditingController _addressController = TextEditingController(text: '123 Business Park, Mumbai, Maharashtra');

  String _businessVertical = 'Retail';
  String _businessCategory = 'Grocery';
  String _stateRegistered = 'Maharashtra';
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _displayTitleController.dispose();
    
    // Dispose transaction prefix controllers
    _salePrefixController.dispose();
    _creditNotePrefixController.dispose();
    _saleOrderPrefixController.dispose();
    _purchaseOrderPrefixController.dispose();
    _estimatePrefixController.dispose();
    _proformaPrefixController.dispose();
    _deliveryChallanPrefixController.dispose();
    _paymentInPrefixController.dispose();

    // Dispose profile controllers
    _businessNameController.dispose();
    _phoneNumberController.dispose();
    _gstinController.dispose();
    _emailController.dispose();
    _booksDateController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.darkText),
                            onPressed: () => Navigator.of(context).maybePop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Advanced Engine Configuration',
                                  style: TextStyle(
                                    color: AppColors.darkText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Manage dynamic deployment switches and metadata',
                                  style: TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            AppSnackbar.show(
                              context,
                              "Deployment successful! System preferences updated globally.",
                              type: SnackType.success,
                            );
                          },
                          icon: const Icon(LucideIcons.rocket, size: 16),
                          label: const Text(
                            'DEPLOY CONFIGURATION',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                    indicatorColor: AppColors.primaryGreen,
                    labelColor: AppColors.primaryGreen,
                    unselectedLabelColor: AppColors.secondaryText,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Org Profile'),
                      Tab(text: 'General'),
                      Tab(text: 'Transaction'),
                      Tab(text: 'Print'),
                      Tab(text: 'Taxes & GST'),
                      Tab(text: 'Contacts'),
                      Tab(text: 'Accounting'),
                      Tab(text: 'Payment'),
                      Tab(text: 'FIN-PRO'),
                      Tab(text: 'Beta Club'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOrgProfileTab(),
              _buildGeneralTab(),
              _buildTransactionTab(),
              _buildPrintTab(),
              _buildTaxesGstTab(),
              _buildContactsTab(),
              _buildAccountingTab(),
              _buildPaymentTab(),
              _buildFinProTab(),
              _buildBetaClubTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTransactionHeaderSection(),
          const SizedBox(height: 16),
          _buildItemsTableSection(),
          const SizedBox(height: 16),
          _buildTaxesDiscountTotalsSection(),
          const SizedBox(height: 16),
          _buildMoreTransactionFeaturesSection(),
          const SizedBox(height: 16),
          _buildTransactionPrefixesSection(),
          const SizedBox(height: 16),
          _buildBillingTypeSection(),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildTransactionHeaderSection() {
    return SettingsSectionCard(
      title: 'Transaction Header',
      icon: const Icon(LucideIcons.layoutPanelTop, size: 18, color: AppColors.primaryGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsCheckbox(
            label: 'Invoice/Bill No.',
            value: _invoiceBillNo,
            onChanged: (v) {
              setState(() {
                _invoiceBillNo = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Add Time on Transactions',
            value: _addTimeOnTransactions,
            onChanged: (v) {
              setState(() {
                _addTimeOnTransactions = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Cash Sale by default',
            value: _cashSaleByDefault,
            onChanged: (v) {
              setState(() {
                _cashSaleByDefault = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Billing Name of Contacts',
            value: _billingNameOfContacts,
            onChanged: (v) {
              setState(() {
                _billingNameOfContacts = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Customers P.O. Details on Transactions',
            value: _customersPoDetails,
            onChanged: (v) {
              setState(() {
                _customersPoDetails = v ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTableSection() {
    return SettingsSectionCard(
      title: 'Items Table',
      icon: const Icon(LucideIcons.listTodo, size: 18, color: AppColors.primaryGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsCheckbox(
            label: 'Inclusive/Exclusive Tax on Rate(Price/Unit)',
            value: _inclusiveTaxOnRate,
            onChanged: (v) {
              setState(() {
                _inclusiveTaxOnRate = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Display Purchase Price of Items',
            value: _displayPurchasePrice,
            onChanged: (v) {
              setState(() {
                _displayPurchasePrice = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Show last 5 Sale Price of Items',
            value: _showLast5SalePrice,
            onChanged: (v) {
              setState(() {
                _showLast5SalePrice = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Show last 5 Purchase Price of Items',
            value: _showLast5PurchasePrice,
            onChanged: (v) {
              setState(() {
                _showLast5PurchasePrice = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Free Item Quantity',
            value: _freeItemQty,
            onChanged: (v) {
              setState(() {
                _freeItemQty = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Count',
            value: _count,
            onChanged: (v) {
              setState(() {
                _count = v ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaxesDiscountTotalsSection() {
    return SettingsSectionCard(
      title: 'Taxes, Discount & Totals',
      icon: const Icon(LucideIcons.calculator, size: 18, color: AppColors.primaryGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsCheckbox(
            label: 'Transaction wise Tax',
            value: _transactionWiseTax,
            onChanged: (v) {
              setState(() {
                _transactionWiseTax = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Transaction wise Discount',
            value: _transactionWiseDiscount,
            onChanged: (v) {
              setState(() {
                _transactionWiseDiscount = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Round Off Total',
            value: _roundOffTotal,
            onChanged: (v) {
              setState(() {
                _roundOffTotal = v ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTransactionFeaturesSection() {
    return SettingsSectionCard(
      title: 'More Transaction Features',
      icon: const Icon(LucideIcons.plusCircle, size: 18, color: AppColors.primaryGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsCheckbox(
            label: 'E-way bill no',
            value: _ewayBillNo,
            onChanged: (v) {
              setState(() {
                _ewayBillNo = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Quick Entry',
            value: _quickEntry,
            onChanged: (v) {
              setState(() {
                _quickEntry = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Do not Show Invoice Preview',
            value: _doNotShowPreview,
            onChanged: (v) {
              setState(() {
                _doNotShowPreview = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Enable Passcode for transaction edit/delete',
            value: _passcodeForEditDelete,
            onChanged: (v) {
              setState(() {
                _passcodeForEditDelete = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Discount During Payments',
            value: _discountDuringPayments,
            onChanged: (v) {
              setState(() {
                _discountDuringPayments = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Link Payments to Invoices',
            value: _linkPaymentsToInvoices,
            onChanged: (v) {
              setState(() {
                _linkPaymentsToInvoices = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Due Dates and Payment Terms',
            value: _dueDatesTerms,
            onChanged: (v) {
              setState(() {
                _dueDatesTerms = v ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          SettingsCheckbox(
            label: 'Show Profit while making Sale Invoice',
            value: _showProfitOnSale,
            onChanged: (v) {
              setState(() {
                _showProfitOnSale = v ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionPrefixesSection() {
    return SettingsSectionCard(
      title: 'Transaction Prefixes',
      icon: const Icon(LucideIcons.edit, size: 18, color: AppColors.primaryGreen),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
        children: [
          SmallSettingsTextField(label: 'Sale', hint: 'INV-', controller: _salePrefixController),
          SmallSettingsTextField(label: 'Credit Note', hint: 'CN-', controller: _creditNotePrefixController),
          SmallSettingsTextField(label: 'Sale Order', hint: 'SO-', controller: _saleOrderPrefixController),
          SmallSettingsTextField(label: 'Purchase Order', hint: 'PO-', controller: _purchaseOrderPrefixController),
          SmallSettingsTextField(label: 'Estimate', hint: 'EST-', controller: _estimatePrefixController),
          SmallSettingsTextField(label: 'Proforma Invoice', hint: 'PRO-', controller: _proformaPrefixController),
          SmallSettingsTextField(label: 'Delivery Challan', hint: 'DC-', controller: _deliveryChallanPrefixController),
          SmallSettingsTextField(label: 'Payment In', hint: 'PAY-', controller: _paymentInPrefixController),
        ],
      ),
    );
  }

  Widget _buildBillingTypeSection() {
    return SettingsSectionCard(
      title: 'Billing Type',
      icon: const Icon(LucideIcons.settings2, size: 18, color: AppColors.primaryGreen),
      child: Row(
        children: [
          Expanded(
            child: SettingsRadioTile<String>(
              label: 'Lite Sale',
              value: 'Lite',
              groupValue: _billingType,
              onChanged: (v) {
                setState(() {
                  _billingType = v ?? 'Lite';
                });
              },
            ),
          ),
          Expanded(
            child: SettingsRadioTile<String>(
              label: 'Full Sale',
              value: 'Full',
              groupValue: _billingType,
              onChanged: (v) {
                setState(() {
                  _billingType = v ?? 'Full';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isMobile)
            Column(
              children: [
                _buildApplicationCoreSection(),
                const SizedBox(height: 16),
                _buildWarehousingSection(),
                const SizedBox(height: 16),
                _buildOperationalFeaturesSection(),
                const SizedBox(height: 16),
                _buildIntegritySection(),
                const SizedBox(height: 16),
                _buildPreferencesSection(),
                const SizedBox(height: 16),
                _buildNotificationsSection(),
                const SizedBox(height: 16),
                _buildPrivacySecuritySection(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildApplicationCoreSection(),
                      const SizedBox(height: 16),
                      _buildOperationalFeaturesSection(),
                      const SizedBox(height: 16),
                      _buildPreferencesSection(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildWarehousingSection(),
                      const SizedBox(height: 16),
                      _buildIntegritySection(),
                      const SizedBox(height: 16),
                      _buildNotificationsSection(),
                      const SizedBox(height: 16),
                      _buildPrivacySecuritySection(),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildApplicationCoreSection() {
    return SettingsSectionCard(
      title: 'Application Core',
      icon: const Icon(LucideIcons.cpu, size: 18, color: AppColors.primaryGreen),
      child: Column(
        children: [
          SettingsSwitchTile(
            title: 'Security Passcode',
            subtitle: 'Validate auth tokens before destructive operations.',
            value: _securityPasscode,
            onChanged: (v) {
              setState(() {
                _securityPasscode = v;
              });
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          SettingsSwitchTile(
            title: 'Prevent Negative Inventory',
            subtitle: 'Restrict invoicing items when stock level <= 0.',
            value: _preventNegativeInventory,
            onChanged: (v) {
              setState(() {
                _preventNegativeInventory = v;
              });
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          SettingsSwitchTile(
            title: 'Lock Contact Generation',
            subtitle: 'Prevent new customer/supplier records within standard forms.',
            value: _lockContactGeneration,
            onChanged: (v) {
              setState(() {
                _lockContactGeneration = v;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWarehousingSection() {
    return SettingsSectionCard(
      title: 'Warehousing',
      icon: const Icon(LucideIcons.repeat, size: 18, color: AppColors.primaryGreen),
      child: Column(
        children: [
          SettingsSwitchTile(
            title: 'Godown Links',
            value: _godownLinks,
            onChanged: (v) {
              setState(() {
                _godownLinks = v;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIntegritySection() {
    return SettingsSectionCard(
      title: 'Integrity',
      icon: const Icon(LucideIcons.database, size: 18, color: AppColors.primaryGreen),
      child: Column(
        children: [
          SettingsSwitchTile(
            title: 'Auto Backup',
            value: _autoBackup,
            onChanged: (v) {
              setState(() {
                _autoBackup = v;
              });
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          SettingsSwitchTile(
            title: 'Audit Trail',
            value: _auditTrail,
            onChanged: (v) {
              setState(() {
                _auditTrail = v;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalFeaturesSection() {
    return SettingsSectionCard(
      title: 'Operational Features',
      icon: const Icon(LucideIcons.package, size: 18, color: AppColors.primaryGreen),
      child: Column(
        children: [
          SettingsSwitchTile(
            title: 'Activate Delivery Challans',
            value: _activateDeliveryChallans,
            onChanged: (v) {
              setState(() {
                _activateDeliveryChallans = v;
              });
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                SettingsCheckbox(
                  label: 'Reverse Goods Logic',
                  value: _reverseGoodsLogic,
                  onChanged: (v) {
                    setState(() {
                      _reverseGoodsLogic = v ?? false;
                    });
                  },
                ),
                SettingsCheckbox(
                  label: 'Display Amount',
                  value: _displayAmount,
                  onChanged: (v) {
                    setState(() {
                      _displayAmount = v ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return SettingsSectionCard(
      title: 'Preferences',
      icon: const Icon(LucideIcons.globe, size: 18, color: AppColors.primaryGreen),
      child: Column(
        children: [
          SettingsSwitchTile(
            title: 'Dark Mode',
            subtitle: 'Use a dark theme for the application interface.',
            value: _darkMode,
            onChanged: (v) {
              setState(() {
                _darkMode = v;
              });
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          SettingsDropdown(
            label: 'Language',
            items: const ['English (US)', 'Hindi', 'Marathi', 'Kannada'],
            value: _language,
            onChanged: (v) {
              setState(() {
                _language = v ?? 'English (US)';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return SettingsSectionCard(
      title: 'Notifications',
      icon: const Icon(LucideIcons.bell, size: 18, color: AppColors.primaryGreen),
      child: Column(
        children: [
          SettingsSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Receive real-time alerts for updates and activities.',
            value: _pushNotifications,
            onChanged: (v) {
              setState(() {
                _pushNotifications = v;
              });
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          SettingsSwitchTile(
            title: 'Email Digest',
            subtitle: 'Receive a weekly summary of your financial activity.',
            value: _emailDigest,
            onChanged: (v) {
              setState(() {
                _emailDigest = v;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySecuritySection() {
    return SettingsSectionCard(
      title: 'Privacy & Security',
      icon: const Icon(LucideIcons.shield, size: 18, color: AppColors.primaryGreen),
      child: Column(
        children: [
          SettingsSwitchTile(
            title: 'Public Profile',
            subtitle: 'Allow other users on the platform to find you.',
            value: _publicProfile,
            onChanged: (v) {
              setState(() {
                _publicProfile = v;
              });
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          SettingsSwitchTile(
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security to your account.',
            value: _twoFactorAuth,
            onChanged: (v) {
              setState(() {
                _twoFactorAuth = v;
              });
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          SettingsSwitchTile(
            title: 'Data & Analytics',
            subtitle: 'Allow usage data to be collected to improve experience.',
            value: _dataAnalytics,
            onChanged: (v) {
              setState(() {
                _dataAnalytics = v;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrgProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding Section
          _buildBrandingSection(),
          const SizedBox(height: 24),

          // Business Details
          SettingsSectionCard(
            title: 'Business Details',
            child: Column(
              children: [
                SettingsTextField(
                  label: 'Business Name',
                  isRequired: true,
                  hint: 'Enter business name',
                  prefixIcon: LucideIcons.building,
                  controller: _businessNameController,
                ),
                const SizedBox(height: 16),
                SettingsTextField(
                  label: 'Phone Number',
                  hint: 'Enter mobile no.',
                  prefixIcon: LucideIcons.phone,
                  controller: _phoneNumberController,
                ),
                const SizedBox(height: 16),
                SettingsTextField(
                  label: 'GSTIN Reference',
                  hint: 'E.g. 27AAAAA0000A1Z5',
                  prefixIcon: LucideIcons.fileDigit,
                  controller: _gstinController,
                ),
                const SizedBox(height: 16),
                SettingsTextField(
                  label: 'Contact Email ID',
                  hint: 'Enter email address',
                  prefixIcon: LucideIcons.mail,
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                SettingsTextField(
                  label: 'Books Beginning Date',
                  hint: 'dd-mm-yyyy',
                  prefixIcon: LucideIcons.calendar,
                  controller: _booksDateController,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Localization
          SettingsSectionCard(
            title: 'Localization',
            child: Column(
              children: [
                SettingsDropdown(
                  label: 'Business Vertical Type',
                  items: const ['Retail', 'Wholesale', 'Service', 'Manufacturing'],
                  value: _businessVertical,
                  onChanged: (v) {
                    setState(() {
                      _businessVertical = v ?? 'Retail';
                    });
                  },
                ),
                const SizedBox(height: 16),
                SettingsDropdown(
                  label: 'Business Category',
                  items: const ['Grocery', 'Electronics', 'Fashion', 'Other'],
                  value: _businessCategory,
                  onChanged: (v) {
                    setState(() {
                      _businessCategory = v ?? 'Grocery';
                    });
                  },
                ),
                const SizedBox(height: 16),
                SettingsDropdown(
                  label: 'State Registered',
                  items: const ['Maharashtra', 'Delhi', 'Karnataka', 'Tamil Nadu'],
                  value: _stateRegistered,
                  onChanged: (v) {
                    setState(() {
                      _stateRegistered = v ?? 'Maharashtra';
                    });
                  },
                ),
                const SizedBox(height: 16),
                SettingsTextField(
                  label: 'Pincode',
                  hint: '6 digit code',
                  prefixIcon: LucideIcons.mapPin,
                  controller: _pincodeController,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Physical Presence
          SettingsSectionCard(
            title: 'Physical Presence',
            child: SettingsTextField(
              label: 'Full Registered Address',
              hint: 'Enter detailed operating address...',
              maxLines: 4,
              controller: _addressController,
            ),
          ),
          const SizedBox(height: 24),

          // Authorized E-Signature
          _buildSignatureSection(),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Future<void> _pickLogoImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final pathLower = pickedFile.path.toLowerCase();
        if (pathLower.endsWith('.pdf')) {
          if (mounted) {
            AppSnackbar.show(
              context,
              "Invalid file format: PDFs are not allowed. Please choose an image.",
              type: SnackType.error,
            );
          }
          return;
        }
        
        setState(() {
          _logoPath = pickedFile.path;
        });
        
        if (mounted) {
          AppSnackbar.show(
            context,
            "Logo updated successfully!",
            type: SnackType.success,
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking logo: $e');
      if (mounted) {
        AppSnackbar.show(
          context,
          "Failed to access gallery: $e. Make sure to rebuild and re-run the app.",
          type: SnackType.error,
        );
      }
    }
  }

  Widget _buildBrandingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Branding',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const Text(
          'This data will be used automatically on all official invoices and emails.',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: _pickLogoImage,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _logoPath != null
                      ? ClipOval(
                          child: Image.file(
                            File(_logoPath!),
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.camera, color: AppColors.secondaryText, size: 28),
                            SizedBox(height: 4),
                            Text(
                              'Add Logo',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.edit2, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Authorized E-Signature',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.uploadCloud, color: AppColors.primaryGreen.withValues(alpha: 0.5), size: 32),
              const SizedBox(height: 8),
              const Text(
                'Upload Signature PNG',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrintTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPrinterMechanismSection(),
          const SizedBox(height: 16),
          _buildInfoOverridesSection(),
          const SizedBox(height: 16),
          _buildViewportPreviewSection(),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildPrinterMechanismSection() {
    return SettingsSectionCard(
      title: 'Printer Mechanism',
      icon: const Icon(LucideIcons.printer, size: 18, color: AppColors.primaryGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTypeToggleItem('REGULAR'),
                ),
                Expanded(
                  child: _buildTypeToggleItem('THERMAL'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SettingsCheckbox(
            label: 'Repeat header on multi-sheet outputs',
            value: _repeatHeader,
            onChanged: (v) {
              setState(() {
                _repeatHeader = v ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggleItem(String type) {
    bool isSelected = _printerType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _printerType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purpleAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoOverridesSection() {
    return SettingsSectionCard(
      title: 'Info Overrides',
      icon: const Icon(LucideIcons.edit3, size: 18, color: AppColors.primaryGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Display Title for Print',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: TextFormField(
              controller: _displayTitleController,
              onChanged: (v) => setState(() {}),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.building, size: 18, color: AppColors.secondaryText),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Page\nDim:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _pageDim,
                      icon: const Icon(LucideIcons.chevronDown, size: 16),
                      isExpanded: true,
                      items: ['A4 Size', 'A5 Size', '3 Inch', '2 Inch'].map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          _pageDim = v ?? 'A4 Size';
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewportPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(LucideIcons.scanEye, size: 18, color: AppColors.purpleAccent),
            SizedBox(width: 8),
            Text(
              'VIEWPORT PREVIEW',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 140,
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _displayTitleController.text,
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Text(
                            'INV-001',
                            style: TextStyle(fontSize: 6, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(height: 4, width: double.infinity, color: AppColors.background),
                      const SizedBox(height: 4),
                      Container(height: 4, width: 80, color: AppColors.background),
                      const SizedBox(height: 4),
                      Container(height: 4, width: 100, color: AppColors.background),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'ACTIVE DIMENSION: ${_pageDim.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaxesGstTab() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SettingsSectionCard(
            title: 'GST Matrix',
            icon: const Icon(LucideIcons.percent, size: 18, color: AppColors.primaryGreen),
            child: Column(
              children: [
                if (isMobile) ...[
                  SettingsSwitchTile(
                    title: 'Enable GST Mode',
                    value: _enableGstMode,
                    onChanged: (v) {
                      setState(() {
                        _enableGstMode = v;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: SettingsCheckbox(
                      label: 'Apply Reverse Charge',
                      value: _applyReverseCharge,
                      onChanged: (v) {
                        setState(() {
                          _applyReverseCharge = v ?? false;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  SettingsSwitchTile(
                    title: 'Force HSN Mandatory',
                    value: _forceHsnMandatory,
                    onChanged: (v) {
                      setState(() {
                        _forceHsnMandatory = v;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: SettingsCheckbox(
                      label: 'Show Place of Supply',
                      value: _showPlaceOfSupply,
                      onChanged: (v) {
                        setState(() {
                          _showPlaceOfSupply = v ?? false;
                        });
                      },
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: SettingsSwitchTile(
                          title: 'Enable GST Mode',
                          value: _enableGstMode,
                          onChanged: (v) {
                            setState(() {
                              _enableGstMode = v;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: SettingsCheckbox(
                          label: 'Apply Reverse Charge',
                          value: _applyReverseCharge,
                          onChanged: (v) {
                            setState(() {
                              _applyReverseCharge = v ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  Row(
                    children: [
                      Expanded(
                        child: SettingsSwitchTile(
                          title: 'Force HSN Mandatory',
                          value: _forceHsnMandatory,
                          onChanged: (v) {
                            setState(() {
                              _forceHsnMandatory = v;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: SettingsCheckbox(
                          label: 'Show Place of Supply',
                          value: _showPlaceOfSupply,
                          onChanged: (v) {
                            setState(() {
                              _showPlaceOfSupply = v ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildContactsTab() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SettingsSectionCard(
            title: 'CRM Features',
            icon: const Icon(LucideIcons.users, size: 18, color: AppColors.primaryGreen),
            child: isMobile
                ? Column(
                    children: [
                      SettingsSwitchTile(
                        title: 'Contact Group Clustering',
                        value: _contactGroupClustering,
                        onChanged: (v) => setState(() => _contactGroupClustering = v),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      SettingsSwitchTile(
                        title: 'Loyalty Contribution',
                        value: _loyaltyContribution,
                        onChanged: (v) => setState(() => _loyaltyContribution = v),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      SettingsSwitchTile(
                        title: 'Active Status Badging',
                        value: _activeStatusBadging,
                        onChanged: (v) => setState(() => _activeStatusBadging = v),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      SettingsSwitchTile(
                        title: 'Auto Reminders',
                        value: _autoReminders,
                        onChanged: (v) => setState(() => _autoReminders = v),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SettingsSwitchTile(
                              title: 'Contact Group Clustering',
                              value: _contactGroupClustering,
                              onChanged: (v) => setState(() => _contactGroupClustering = v),
                            ),
                            const Divider(height: 1, color: AppColors.border),
                            SettingsSwitchTile(
                              title: 'Active Status Badging',
                              value: _activeStatusBadging,
                              onChanged: (v) => setState(() => _activeStatusBadging = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          children: [
                            SettingsSwitchTile(
                              title: 'Loyalty Contribution',
                              value: _loyaltyContribution,
                              onChanged: (v) => setState(() => _loyaltyContribution = v),
                            ),
                            const Divider(height: 1, color: AppColors.border),
                            SettingsSwitchTile(
                              title: 'Auto Reminders',
                              value: _autoReminders,
                              onChanged: (v) => setState(() => _autoReminders = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildAccountingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SettingsSectionCard(
            title: 'Double Entry Accounting',
            icon: const Icon(LucideIcons.bookOpen, size: 18, color: AppColors.primaryGreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enabling the accounting engine activates journal vouchers, ledger mapping, auto-balancing trial sheets, and real-time P&L generated directly from system debits and credits.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SettingsSwitchTile(
                  title: 'Enable Full-Scale Accounting Module',
                  subtitle: 'Unlock advanced balance sheet mechanics.',
                  value: _enableAccountingModule,
                  onChanged: (v) => setState(() => _enableAccountingModule = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildPaymentTab() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isMobile)
            Column(
              children: [
                _buildPaymentIntegrationRules(),
                const SizedBox(height: 16),
                _buildRealtimePaymentPreview(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildPaymentIntegrationRules()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildRealtimePaymentPreview()),
              ],
            ),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildPaymentIntegrationRules() {
    return SettingsSectionCard(
      title: 'Payment Integration Rules',
      icon: const Icon(LucideIcons.link2, size: 18, color: AppColors.primaryGreen),
      child: Column(
        children: [
          SettingsSwitchTile(
            title: 'Instant UPI Dynamic QR Generation',
            subtitle: 'Embed auto-generated dynamic UPI QR codes on all invoices for instant customer scans.',
            value: _instantUpiQr,
            onChanged: (v) => setState(() => _instantUpiQr = v),
          ),
          const Divider(height: 24, color: AppColors.border),
          SettingsSwitchTile(
            title: 'Card Payment Settlements',
            subtitle: 'Support direct credit/debit card transactions (Visa, Mastercard, RuPay) during billing checkout.',
            value: _cardPaymentSettlements,
            onChanged: (v) => setState(() => _cardPaymentSettlements = v),
          ),
          const Divider(height: 24, color: AppColors.border),
          SettingsSwitchTile(
            title: 'Automated Outstanding Reminders',
            subtitle: 'Automatically ping customers via WhatsApp/SMS when invoice due date is near or elapsed.',
            value: _automatedReminders,
            onChanged: (v) => setState(() => _automatedReminders = v),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimePaymentPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(LucideIcons.scanEye, size: 18, color: AppColors.blue),
            SizedBox(width: 8),
            Text(
              'REALTIME PAYMENT PREVIEW',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MERCHANT ACCOUNT',
                              style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'ravikumarlaptop',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Icon(LucideIcons.nfc, color: Colors.white, size: 20),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            'AMOUNT DUE',
                            style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹ 5,249.00',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Image.network(
                              'https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=UPIDemo',
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.qrCode, size: 100, color: AppColors.darkText),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'BHIM UPI SECURED',
                              style: TextStyle(color: AppColors.primaryGreen, fontSize: 7, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: Colors.white54, size: 6),
                            SizedBox(width: 4),
                            Text('VISA/MC Card', style: TextStyle(color: Colors.white, fontSize: 8)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.circle, color: AppColors.primaryGreen, size: 6),
                            SizedBox(width: 4),
                            Text('Auto SMS Reminders', style: TextStyle(color: Colors.white, fontSize: 8)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinProTab() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isMobile)
            Column(
              children: [
                _buildProfessionalLedgerSection(),
                const SizedBox(height: 16),
                _buildFinProPlatinumSuiteCard(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildProfessionalLedgerSection()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildFinProPlatinumSuiteCard()),
              ],
            ),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildProfessionalLedgerSection() {
    return SettingsSectionCard(
      title: 'Professional Ledger & AI Analytics',
      icon: const Icon(LucideIcons.sparkles, size: 18, color: AppColors.primaryGreen),
      child: Column(
        children: [
          SettingsSwitchTile(
            title: 'Multi-Currency Ledgers',
            subtitle: 'Enable cross-border entries with real-time currency conversions and daily forex adjustments.',
            value: _multiCurrencyLedgers,
            onChanged: (v) => setState(() => _multiCurrencyLedgers = v),
          ),
          const Divider(height: 24, color: AppColors.border),
          SettingsSwitchTile(
            title: 'AI Predictive Cashflow Projections',
            subtitle: 'Activate self-learning neural engines to forecast cash runways, collections, and burn rates.',
            value: _aiCashflowProjections,
            onChanged: (v) => setState(() => _aiCashflowProjections = v),
          ),
          const Divider(height: 24, color: AppColors.border),
          SettingsSwitchTile(
            title: 'Smart Audit Trail GST Sync',
            subtitle: 'Maintain a cryptographically hashed log of every invoice action with instant tax node parity.',
            value: _smartAuditGstSync,
            onChanged: (v) => setState(() => _smartAuditGstSync = v),
          ),
        ],
      ),
    );
  }

  Widget _buildFinProPlatinumSuiteCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(LucideIcons.crown, size: 18, color: Color(0xFFFFD700)),
            SizedBox(width: 8),
            Text(
              'FIN-PRO PLATINUM SUITE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1E2C), Color(0xFF111119)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ENTERPRISE LAYER',
                              style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text(
                                  'FIN-PRO',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF2D55).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFF2D55).withValues(alpha: 0.5)),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(color: Color(0xFFFF2D55), fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(LucideIcons.zap, color: Color(0xFFFFD700), size: 24),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildFinProStatusItem(LucideIcons.globe, 'Multi-Currency Ledger', 'LOCAL CURRENCY ONLY', Colors.white38),
                    const SizedBox(height: 12),
                    _buildFinProStatusItem(LucideIcons.brainCircuit, 'AI Cashflow Engine', 'PREDICTIVE ANALYSIS UP', const Color(0xFF4CD964)),
                    const SizedBox(height: 12),
                    _buildFinProStatusItem(LucideIcons.shieldCheck, 'Hashed GST Node Sync', 'OFFLINE', Colors.white24),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI RUNAWAY PROJECTION (30 DAYS)',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          '₹ 14.8L Safe Reserve',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+8.4% growth forecasted',
                          style: TextStyle(color: const Color(0xFF4CD964).withValues(alpha: 0.8), fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinProStatusItem(IconData icon, String label, String status, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white38, size: 14),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
        Text(status, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBetaClubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.02),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.crown, color: Color(0xFFFFD700), size: 64)
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 2.seconds, color: Colors.white30)
                      .moveY(begin: -5, end: 5, duration: 1500.ms, curve: Curves.easeInOutSine),
                  const SizedBox(height: 32),
                  const Text(
                    'Join the Beta Club',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gain exclusive early access to experimental features, AI-powered insights, and advanced integrations before they roll out to the public.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AppSnackbar.show(
                          context,
                          "Application received! We'll notify you once your beta registration is verified.",
                          type: SnackType.success,
                        );
                      },
                      icon: const Icon(LucideIcons.partyPopper, size: 18),
                      label: const Text(
                        'APPLY FOR ACCESS',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF1E1E2C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().scale(begin: const Offset(0.95, 0.95), duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
