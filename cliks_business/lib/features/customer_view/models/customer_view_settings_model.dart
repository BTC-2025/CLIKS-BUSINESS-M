class CustomerViewSettings {
  // Display & Branding
  final String businessName;
  final String welcomeHeadline;
  final String welcomeSubtitle;
  final bool showBusinessName;
  final bool showBusinessLogo;
  final bool showWelcomeMessage;
  final bool showProductDescriptions;
  final bool showProductImages;
  final bool showProductCategories;
  final bool showProductSku;
  final bool showProductAvailability;
  final bool showGstBreakdown;
  final bool collectCustomerDetails;
  final bool requireCustomerPhone;
  final bool allowOrderTypeSelection;
  final bool showPreparationTimer;
  final bool showOrderNumber;
  final bool showCartSummary;

  // Typography & Fonts
  final String fontFamily; // 'Inter', 'Poppins', 'Roboto', 'Outfit', 'Montserrat', 'Plus Jakarta Sans', 'Playfair Display', 'DM Sans'
  final double fontSizeScale; // 0.9, 1.0, 1.1, 1.2
  final String fontWeightPreset; // 'Light', 'Standard', 'Bold'

  // Appearance & Themes
  final String themePreset; // 'emerald_gourmet', 'tokyo_amber', 'cyber_indigo', 'ruby_velvet', 'sunset_gold', 'midnight_luxury', 'custom'
  final int primaryColorValue;
  final int accentColorValue;
  final bool isDarkMode;
  final String productCardStyle; // 'modern', 'bordered', 'compact', 'minimal'
  final double borderRadius; // 8.0, 14.0, 20.0, 28.0
  final String headerStyle; // 'clean', 'gradient', 'brand'
  final String surfaceTint; // 'default', 'cream', 'frost', 'slate'

  // Advanced Promotional Banner
  final bool showPromoBanner;
  final String promoBannerTitle;
  final String promoBannerSubtitle;
  final String promoBannerStyle; // 'fire', 'gold', 'indigo', 'emerald'

  // Attract Screen & Idle Kiosk Mode
  final bool enableAttractScreen;
  final String attractHeadline;
  final String attractSubtitle;
  final int idleTimeoutSeconds;

  // Ordering & Timer Settings
  final bool enableSelfOrdering;
  final bool enableCart;
  final int defaultPreparationMinutes;
  final List<String> enabledPaymentModes;
  final bool enableDietaryFilters;
  final bool enableUpsellRecommendations;
  final String kitchenSlipMode;
  final bool enableSoundEffects;

  // Currency, Taxes & Badges
  final String currencySymbol; // '₹', '$', '€', '£', 'AED'
  final String taxDisplayMode; // 'breakdown', 'inclusive', 'hidden'
  final bool showCalories;
  final bool showPrepTimeBadge;
  final bool showTableNumberInput;
  final bool requireTableNumber;

  const CustomerViewSettings({
    this.businessName = 'Cliks Express & Gourmet Dining',
    this.welcomeHeadline = 'Self-Ordering Kiosk',
    this.welcomeSubtitle = 'Explore our handcrafted menu, customize & checkout in seconds',
    this.showBusinessName = true,
    this.showBusinessLogo = true,
    this.showWelcomeMessage = true,
    this.showProductDescriptions = true,
    this.showProductImages = true,
    this.showProductCategories = true,
    this.showProductSku = false,
    this.showProductAvailability = true,
    this.showGstBreakdown = true,
    this.collectCustomerDetails = true,
    this.requireCustomerPhone = false,
    this.allowOrderTypeSelection = true,
    this.showPreparationTimer = true,
    this.showOrderNumber = true,
    this.showCartSummary = true,
    this.fontFamily = 'Inter',
    this.fontSizeScale = 1.0,
    this.fontWeightPreset = 'Standard',
    this.themePreset = 'emerald_gourmet',
    this.primaryColorValue = 0xFF059669, // Emerald Gourmet
    this.accentColorValue = 0xFFF59E0B,  // Amber Gold
    this.isDarkMode = false,
    this.productCardStyle = 'modern',
    this.borderRadius = 16.0,
    this.headerStyle = 'clean',
    this.surfaceTint = 'default',
    this.showPromoBanner = true,
    this.promoBannerTitle = '🔥 TODAY SPECIAL: GET 50% OFF ALL BEVERAGES WITH ANY GOURMET COMBO!',
    this.promoBannerSubtitle = 'Freshly crafted to order. Tap any meal to customize with favorite dips & sides.',
    this.promoBannerStyle = 'fire',
    this.enableAttractScreen = false,
    this.attractHeadline = 'Touch Anywhere on Screen to Start Ordering',
    this.attractSubtitle = 'Explore our handcrafted gourmet menu, customize & checkout in seconds',
    this.idleTimeoutSeconds = 90,
    this.enableSelfOrdering = true,
    this.enableCart = true,
    this.defaultPreparationMinutes = 12,
    this.enabledPaymentModes = const [
      'Pay at Counter',
      'UPI QR Code',
      'Card Machine',
    ],
    this.enableDietaryFilters = true,
    this.enableUpsellRecommendations = true,
    this.kitchenSlipMode = 'Digital Token Only',
    this.enableSoundEffects = true,
    this.currencySymbol = '₹',
    this.taxDisplayMode = 'breakdown',
    this.showCalories = true,
    this.showPrepTimeBadge = true,
    this.showTableNumberInput = true,
    this.requireTableNumber = false,
  });

  CustomerViewSettings copyWith({
    String? businessName,
    String? welcomeHeadline,
    String? welcomeSubtitle,
    bool? showBusinessName,
    bool? showBusinessLogo,
    bool? showWelcomeMessage,
    bool? showProductDescriptions,
    bool? showProductImages,
    bool? showProductCategories,
    bool? showProductSku,
    bool? showProductAvailability,
    bool? showGstBreakdown,
    bool? collectCustomerDetails,
    bool? requireCustomerPhone,
    bool? allowOrderTypeSelection,
    bool? showPreparationTimer,
    bool? showOrderNumber,
    bool? showCartSummary,
    String? fontFamily,
    double? fontSizeScale,
    String? fontWeightPreset,
    String? themePreset,
    int? primaryColorValue,
    int? accentColorValue,
    bool? isDarkMode,
    String? productCardStyle,
    double? borderRadius,
    String? headerStyle,
    String? surfaceTint,
    bool? showPromoBanner,
    String? promoBannerTitle,
    String? promoBannerSubtitle,
    String? promoBannerStyle,
    bool? enableAttractScreen,
    String? attractHeadline,
    String? attractSubtitle,
    int? idleTimeoutSeconds,
    bool? enableSelfOrdering,
    bool? enableCart,
    int? defaultPreparationMinutes,
    List<String>? enabledPaymentModes,
    bool? enableDietaryFilters,
    bool? enableUpsellRecommendations,
    String? kitchenSlipMode,
    bool? enableSoundEffects,
    String? currencySymbol,
    String? taxDisplayMode,
    bool? showCalories,
    bool? showPrepTimeBadge,
    bool? showTableNumberInput,
    bool? requireTableNumber,
  }) {
    return CustomerViewSettings(
      businessName: businessName ?? this.businessName,
      welcomeHeadline: welcomeHeadline ?? this.welcomeHeadline,
      welcomeSubtitle: welcomeSubtitle ?? this.welcomeSubtitle,
      showBusinessName: showBusinessName ?? this.showBusinessName,
      showBusinessLogo: showBusinessLogo ?? this.showBusinessLogo,
      showWelcomeMessage: showWelcomeMessage ?? this.showWelcomeMessage,
      showProductDescriptions:
          showProductDescriptions ?? this.showProductDescriptions,
      showProductImages: showProductImages ?? this.showProductImages,
      showProductCategories:
          showProductCategories ?? this.showProductCategories,
      showProductSku: showProductSku ?? this.showProductSku,
      showProductAvailability:
          showProductAvailability ?? this.showProductAvailability,
      showGstBreakdown: showGstBreakdown ?? this.showGstBreakdown,
      collectCustomerDetails:
          collectCustomerDetails ?? this.collectCustomerDetails,
      requireCustomerPhone: requireCustomerPhone ?? this.requireCustomerPhone,
      allowOrderTypeSelection:
          allowOrderTypeSelection ?? this.allowOrderTypeSelection,
      showPreparationTimer: showPreparationTimer ?? this.showPreparationTimer,
      showOrderNumber: showOrderNumber ?? this.showOrderNumber,
      showCartSummary: showCartSummary ?? this.showCartSummary,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      fontWeightPreset: fontWeightPreset ?? this.fontWeightPreset,
      themePreset: themePreset ?? this.themePreset,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      productCardStyle: productCardStyle ?? this.productCardStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      headerStyle: headerStyle ?? this.headerStyle,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      showPromoBanner: showPromoBanner ?? this.showPromoBanner,
      promoBannerTitle: promoBannerTitle ?? this.promoBannerTitle,
      promoBannerSubtitle: promoBannerSubtitle ?? this.promoBannerSubtitle,
      promoBannerStyle: promoBannerStyle ?? this.promoBannerStyle,
      enableAttractScreen: enableAttractScreen ?? this.enableAttractScreen,
      attractHeadline: attractHeadline ?? this.attractHeadline,
      attractSubtitle: attractSubtitle ?? this.attractSubtitle,
      idleTimeoutSeconds: idleTimeoutSeconds ?? this.idleTimeoutSeconds,
      enableSelfOrdering: enableSelfOrdering ?? this.enableSelfOrdering,
      enableCart: enableCart ?? this.enableCart,
      defaultPreparationMinutes:
          defaultPreparationMinutes ?? this.defaultPreparationMinutes,
      enabledPaymentModes: enabledPaymentModes ?? this.enabledPaymentModes,
      enableDietaryFilters: enableDietaryFilters ?? this.enableDietaryFilters,
      enableUpsellRecommendations:
          enableUpsellRecommendations ?? this.enableUpsellRecommendations,
      kitchenSlipMode: kitchenSlipMode ?? this.kitchenSlipMode,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      taxDisplayMode: taxDisplayMode ?? this.taxDisplayMode,
      showCalories: showCalories ?? this.showCalories,
      showPrepTimeBadge: showPrepTimeBadge ?? this.showPrepTimeBadge,
      showTableNumberInput: showTableNumberInput ?? this.showTableNumberInput,
      requireTableNumber: requireTableNumber ?? this.requireTableNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'welcomeHeadline': welcomeHeadline,
      'welcomeSubtitle': welcomeSubtitle,
      'showBusinessName': showBusinessName,
      'showBusinessLogo': showBusinessLogo,
      'showWelcomeMessage': showWelcomeMessage,
      'showProductDescriptions': showProductDescriptions,
      'showProductImages': showProductImages,
      'showProductCategories': showProductCategories,
      'showProductSku': showProductSku,
      'showProductAvailability': showProductAvailability,
      'showGstBreakdown': showGstBreakdown,
      'collectCustomerDetails': collectCustomerDetails,
      'requireCustomerPhone': requireCustomerPhone,
      'allowOrderTypeSelection': allowOrderTypeSelection,
      'showPreparationTimer': showPreparationTimer,
      'showOrderNumber': showOrderNumber,
      'showCartSummary': showCartSummary,
      'fontFamily': fontFamily,
      'fontSizeScale': fontSizeScale,
      'fontWeightPreset': fontWeightPreset,
      'themePreset': themePreset,
      'primaryColorValue': primaryColorValue,
      'accentColorValue': accentColorValue,
      'isDarkMode': isDarkMode,
      'productCardStyle': productCardStyle,
      'borderRadius': borderRadius,
      'headerStyle': headerStyle,
      'surfaceTint': surfaceTint,
      'showPromoBanner': showPromoBanner,
      'promoBannerTitle': promoBannerTitle,
      'promoBannerSubtitle': promoBannerSubtitle,
      'promoBannerStyle': promoBannerStyle,
      'enableAttractScreen': enableAttractScreen,
      'attractHeadline': attractHeadline,
      'attractSubtitle': attractSubtitle,
      'idleTimeoutSeconds': idleTimeoutSeconds,
      'enableSelfOrdering': enableSelfOrdering,
      'enableCart': enableCart,
      'defaultPreparationMinutes': defaultPreparationMinutes,
      'enabledPaymentModes': enabledPaymentModes,
      'enableDietaryFilters': enableDietaryFilters,
      'enableUpsellRecommendations': enableUpsellRecommendations,
      'kitchenSlipMode': kitchenSlipMode,
      'enableSoundEffects': enableSoundEffects,
      'currencySymbol': currencySymbol,
      'taxDisplayMode': taxDisplayMode,
      'showCalories': showCalories,
      'showPrepTimeBadge': showPrepTimeBadge,
      'showTableNumberInput': showTableNumberInput,
      'requireTableNumber': requireTableNumber,
    };
  }

  factory CustomerViewSettings.fromJson(Map<String, dynamic> json) {
    return CustomerViewSettings(
      businessName: json['businessName']?.toString() ??
          'Cliks Express & Gourmet Dining',
      welcomeHeadline:
          json['welcomeHeadline']?.toString() ?? 'Self-Ordering Kiosk',
      welcomeSubtitle: json['welcomeSubtitle']?.toString() ??
          'Explore our handcrafted menu, customize & checkout in seconds',
      showBusinessName: json['showBusinessName'] ?? true,
      showBusinessLogo: json['showBusinessLogo'] ?? true,
      showWelcomeMessage: json['showWelcomeMessage'] ?? true,
      showProductDescriptions: json['showProductDescriptions'] ?? true,
      showProductImages: json['showProductImages'] ?? true,
      showProductCategories: json['showProductCategories'] ?? true,
      showProductSku: json['showProductSku'] ?? false,
      showProductAvailability: json['showProductAvailability'] ?? true,
      showGstBreakdown: json['showGstBreakdown'] ?? true,
      collectCustomerDetails: json['collectCustomerDetails'] ?? true,
      requireCustomerPhone: json['requireCustomerPhone'] ?? false,
      allowOrderTypeSelection: json['allowOrderTypeSelection'] ?? true,
      showPreparationTimer: json['showPreparationTimer'] ?? true,
      showOrderNumber: json['showOrderNumber'] ?? true,
      showCartSummary: json['showCartSummary'] ?? true,
      fontFamily: json['fontFamily']?.toString() ?? 'Inter',
      fontSizeScale: (json['fontSizeScale'] as num?)?.toDouble() ?? 1.0,
      fontWeightPreset: json['fontWeightPreset']?.toString() ?? 'Standard',
      themePreset: json['themePreset']?.toString() ?? 'emerald_gourmet',
      primaryColorValue:
          (json['primaryColorValue'] as num?)?.toInt() ?? 0xFF059669,
      accentColorValue:
          (json['accentColorValue'] as num?)?.toInt() ?? 0xFFF59E0B,
      isDarkMode: json['isDarkMode'] ?? false,
      productCardStyle: json['productCardStyle']?.toString() ?? 'modern',
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 16.0,
      headerStyle: json['headerStyle']?.toString() ?? 'clean',
      surfaceTint: json['surfaceTint']?.toString() ?? 'default',
      showPromoBanner: json['showPromoBanner'] ?? true,
      promoBannerTitle: json['promoBannerTitle']?.toString() ??
          '🔥 TODAY SPECIAL: GET 50% OFF ALL BEVERAGES WITH ANY GOURMET COMBO!',
      promoBannerSubtitle: json['promoBannerSubtitle']?.toString() ??
          'Freshly crafted to order. Tap any meal to customize with favorite dips & sides.',
      promoBannerStyle: json['promoBannerStyle']?.toString() ?? 'fire',
      enableAttractScreen: json['enableAttractScreen'] ?? false,
      attractHeadline: json['attractHeadline']?.toString() ??
          'Touch Anywhere on Screen to Start Ordering',
      attractSubtitle: json['attractSubtitle']?.toString() ??
          'Explore our handcrafted gourmet menu, customize & checkout in seconds',
      idleTimeoutSeconds:
          (json['idleTimeoutSeconds'] as num?)?.toInt() ?? 90,
      enableSelfOrdering: json['enableSelfOrdering'] ?? true,
      enableCart: json['enableCart'] ?? true,
      defaultPreparationMinutes:
          (json['defaultPreparationMinutes'] as num?)?.toInt() ?? 12,
      enabledPaymentModes: (json['enabledPaymentModes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Pay at Counter', 'UPI QR Code', 'Card Machine'],
      enableDietaryFilters: json['enableDietaryFilters'] ?? true,
      enableUpsellRecommendations:
          json['enableUpsellRecommendations'] ?? true,
      kitchenSlipMode:
          json['kitchenSlipMode']?.toString() ?? 'Digital Token Only',
      enableSoundEffects: json['enableSoundEffects'] ?? true,
      currencySymbol: json['currencySymbol']?.toString() ?? '₹',
      taxDisplayMode: json['taxDisplayMode']?.toString() ?? 'breakdown',
      showCalories: json['showCalories'] ?? true,
      showPrepTimeBadge: json['showPrepTimeBadge'] ?? true,
      showTableNumberInput: json['showTableNumberInput'] ?? true,
      requireTableNumber: json['requireTableNumber'] ?? false,
    );
  }
}
