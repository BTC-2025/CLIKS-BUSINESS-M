class CustomerViewSettings {
  // Display settings
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

  // Advanced Promotional Banner
  final bool showPromoBanner;
  final String promoBannerTitle;
  final String promoBannerSubtitle;

  // Attract Screen & Idle Kiosk Mode
  final bool enableAttractScreen;
  final String attractHeadline;
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

  // Appearance & Themes
  final String themePreset; // 'emerald_gourmet', 'tokyo_amber', 'cyber_indigo', 'ruby_velvet', 'sunset_gold', 'midnight_luxury'
  final int primaryColorValue;
  final int accentColorValue;
  final bool isDarkMode;
  final String productCardStyle; // 'modern', 'bordered', 'compact'

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
    this.showPromoBanner = true,
    this.promoBannerTitle = '🔥 TODAY SPECIAL: GET 50% OFF ALL BEVERAGES WITH ANY GOURMET COMBO!',
    this.promoBannerSubtitle = 'Freshly crafted to order. Tap any meal to customize with favorite dips & sides.',
    this.enableAttractScreen = false,
    this.attractHeadline = 'Touch Anywhere on Screen to Start Ordering',
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
    this.themePreset = 'emerald_gourmet',
    this.primaryColorValue = 0xFF059669, // Emerald Gourmet
    this.accentColorValue = 0xFFF59E0B,  // Amber Gold
    this.isDarkMode = false,
    this.productCardStyle = 'modern',
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
    bool? showPromoBanner,
    String? promoBannerTitle,
    String? promoBannerSubtitle,
    bool? enableAttractScreen,
    String? attractHeadline,
    int? idleTimeoutSeconds,
    bool? enableSelfOrdering,
    bool? enableCart,
    int? defaultPreparationMinutes,
    List<String>? enabledPaymentModes,
    bool? enableDietaryFilters,
    bool? enableUpsellRecommendations,
    String? kitchenSlipMode,
    bool? enableSoundEffects,
    String? themePreset,
    int? primaryColorValue,
    int? accentColorValue,
    bool? isDarkMode,
    String? productCardStyle,
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
      showPromoBanner: showPromoBanner ?? this.showPromoBanner,
      promoBannerTitle: promoBannerTitle ?? this.promoBannerTitle,
      promoBannerSubtitle: promoBannerSubtitle ?? this.promoBannerSubtitle,
      enableAttractScreen: enableAttractScreen ?? this.enableAttractScreen,
      attractHeadline: attractHeadline ?? this.attractHeadline,
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
      themePreset: themePreset ?? this.themePreset,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      productCardStyle: productCardStyle ?? this.productCardStyle,
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
      'showPromoBanner': showPromoBanner,
      'promoBannerTitle': promoBannerTitle,
      'promoBannerSubtitle': promoBannerSubtitle,
      'enableAttractScreen': enableAttractScreen,
      'attractHeadline': attractHeadline,
      'idleTimeoutSeconds': idleTimeoutSeconds,
      'enableSelfOrdering': enableSelfOrdering,
      'enableCart': enableCart,
      'defaultPreparationMinutes': defaultPreparationMinutes,
      'enabledPaymentModes': enabledPaymentModes,
      'enableDietaryFilters': enableDietaryFilters,
      'enableUpsellRecommendations': enableUpsellRecommendations,
      'kitchenSlipMode': kitchenSlipMode,
      'enableSoundEffects': enableSoundEffects,
      'themePreset': themePreset,
      'primaryColorValue': primaryColorValue,
      'accentColorValue': accentColorValue,
      'isDarkMode': isDarkMode,
      'productCardStyle': productCardStyle,
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
      showPromoBanner: json['showPromoBanner'] ?? true,
      promoBannerTitle: json['promoBannerTitle']?.toString() ??
          '🔥 TODAY SPECIAL: GET 50% OFF ALL BEVERAGES WITH ANY GOURMET COMBO!',
      promoBannerSubtitle: json['promoBannerSubtitle']?.toString() ??
          'Freshly crafted to order. Tap any meal to customize with favorite dips & sides.',
      enableAttractScreen: json['enableAttractScreen'] ?? false,
      attractHeadline: json['attractHeadline']?.toString() ??
          'Touch Anywhere on Screen to Start Ordering',
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
      themePreset: json['themePreset']?.toString() ?? 'emerald_gourmet',
      primaryColorValue:
          (json['primaryColorValue'] as num?)?.toInt() ?? 0xFF059669,
      accentColorValue:
          (json['accentColorValue'] as num?)?.toInt() ?? 0xFFF59E0B,
      isDarkMode: json['isDarkMode'] ?? false,
      productCardStyle: json['productCardStyle']?.toString() ?? 'modern',
    );
  }
}
